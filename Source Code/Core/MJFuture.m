//
// Copyright 2017 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MJFuture.h"

NSString * const MJFutureValueNotAvailableException = @"MJFutureValueNotAvailableException";
NSString * const MJFutureErrorKey = @"MJFutureErrorKey";

#define MJFutureDuplicateInvocationException(method) [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"MJFuture doesn't allow calling twice the method <%@>.", NSStringFromSelector(@selector(method))] userInfo:nil]

#define MJFutureAlreadySentException [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Future already sent." userInfo:nil]

@interface MJFuture()

@property (nonatomic, copy, readwrite) void (^thenBlock)(id, NSError *);

@end

@implementation MJFuture
{
	id _value;
	id _error;
	
	dispatch_queue_t _customQueue;
    
    dispatch_semaphore_t _semaphore;
	
	NSHashTable <id <MJFutureObserver>> *_observers;
}

+ (MJFuture *)emptyFuture
{
	MJFuture *future = [[MJFuture alloc] init];
	return future;
}

+ (MJFuture*)immediateFuture:(id)value
{
	MJFuture *future = [[MJFuture alloc] init];
	[future setValue:value];
	return future;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_state = MJFutureStateBlank;
		_returnQueue = dispatch_get_main_queue();
		_observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
	}
	return self;
}

- (void)setValue:(id)value
{
	@synchronized (self)
	{
		if (_value)
		{
			[MJFutureDuplicateInvocationException(setValue:) raise];
		}
		
		_value = value;
		
		[_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([obj respondsToSelector:@selector(future:didSetValue:)])
			{
				[obj future:self didSetValue:value];
			}
		}];
		
		[self mjz_update];
	}
}

- (void)setError:(NSError *)error
{
	@synchronized (self)
	{
		if (_error)
		{
			[MJFutureDuplicateInvocationException(setError:) raise];
		}
		
		_error = error;
		
		[_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if ([obj respondsToSelector:@selector(future:didSetError:)])
			{
				[obj future:self didSetError:error];
			}
		}];
		
		[self mjz_update];
	}
}

- (void)wontHappen
{
	_state = MJFutureStateWontHappen;
	
	[_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if ([obj respondsToSelector:@selector(wontHappenFuture:)])
		{
			[obj wontHappenFuture:self];
		}
	}];
}

- (void)then:(void (^)(id, NSError *))block
{
	[self then:block inQueue:nil];
}

- (void)then:(void (^)(id, NSError *))block inQueue:(dispatch_queue_t)queue
{
	@synchronized (self)
	{
		if (_thenBlock)
		{
			[MJFutureDuplicateInvocationException(then:) raise];
		}
		
		self.thenBlock = block;
		_customQueue = queue;
		
		[self mjz_update];
	}
}

- (_Nullable id)value
{
    if (_state == MJFutureStateWaitingBlock)
    {
        if (_value)
        {
            _state = MJFutureStateSent;
            return _value;
        }
        else if (_error)
        {
            NSException *exception = [NSException exceptionWithName:MJFutureValueNotAvailableException
                                                             reason:@"Value is not available."
                                                           userInfo:@{MJFutureErrorKey: _error}];
            @throw exception;
        }
        else
        {
            NSAssert(NO, @"Invalid future state");
        }
    }
    else if (_state == MJFutureStateBlank)
    {
        _semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        
        return [self value];
    }
    else
    {
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                         reason:@"Misusage of futre"
                                                       userInfo:nil];
        @throw exception;
    }
    
    return nil;
}

- (void)addObserver:(id <MJFutureObserver>)observer
{
	[_observers addObject:observer];
	
	if (_state == MJFutureStateSent || _state == MJFutureStateWaitingBlock)
	{
		if (_value)
		{
			if ([observer respondsToSelector:@selector(future:didSetValue:)])
			{
				[observer future:self didSetValue:_value];
			}
		}
		else if (_error)
		{
			if ([observer respondsToSelector:@selector(future:didSetError:)])
			{
				[observer future:self didSetError:_error];
			}
		}
	}
	else if (_state == MJFutureStateWontHappen)
	{
		if ([observer respondsToSelector:@selector(wontHappenFuture:)])
		{
			[observer wontHappenFuture:self];
		}
	}
}

- (void)removeObserver:(id <MJFutureObserver>)observer
{
	[_observers removeObject:observer];
}

#pragma mark Private Methods

- (void)mjz_update
{
	if (_state == MJFutureStateSent)
	{
		[MJFutureAlreadySentException raise];
	}
	else if (_state == MJFutureStateBlank)
	{
		// Waiting for either value||error , or the then block.
		
		if (_value || _error)
		{
			_state = MJFutureStateWaitingBlock;
            
            if (_semaphore != nil)
            {
                dispatch_semaphore_signal(_semaphore);
            }
		}
		else if (_thenBlock)
		{
			_state = MJFutureStateWaitingValueOrError;
		}
	}
	else if (_state == MJFutureStateWaitingBlock)
	{
		if	(_thenBlock)
		{
			[self mjz_send];
			_state = MJFutureStateSent;
		}
	}
	else if (_state == MJFutureStateWaitingValueOrError)
	{
		if (_value || _error)
		{
			[self mjz_send];
			_state = MJFutureStateSent;
		}
	}
}

- (void)mjz_send
{
	void (^thenBlock)(id, NSError *) = _thenBlock;
	id value = _value;
	id error = _error;
	
	if (_customQueue)
	{
		dispatch_async(_customQueue, ^{
			thenBlock(value, error);
		});
	}
	else
	{
		dispatch_async(_returnQueue, ^{
			thenBlock(value, error);
		});
	}
	
	[_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if ([obj respondsToSelector:@selector(didSendFuture:)])
		{
			[obj didSendFuture:self];
		}
	}];
	
	self.thenBlock = nil;
	_value = nil;
	_error = nil;
	_customQueue = nil;
}

@end
