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

#define MJFutureDuplicateInvocationException(method) [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"MJFuture doesn't allow calling twice the method <%@>.", NSStringFromSelector(@selector(method))] userInfo:nil]

#define MJFutureAlreadySentException [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Future already sent." userInfo:nil]

@implementation MJFuture
{
    id _value;
    id _error;
    
    void (^_thenBlock)(id, NSError *);
    
    dispatch_queue_t _customQueue;
    
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
        
        _thenBlock = block;
        _customQueue = queue;
        
        [self mjz_update];
    }
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
    else
    {
        if ((_value || _error) && !_thenBlock)
        {
            _state = MJFutureStateWaitingBlock;
        }
        else if (_thenBlock && (!_value && !_error))
        {
            _state = MJFutureStateWaitingValueOrError;
        }
        else if (_thenBlock && (_value || _error))
        {
            
            if (_customQueue)
            {
                dispatch_async(_customQueue, ^{
                    _thenBlock(_value, _error);
                });
            }
            else if (_returnQueue)
            {
                dispatch_async(_returnQueue, ^{
                    _thenBlock(_value, _error);
                });
            }
            else
            {
                _thenBlock(_value, _error);
            }
            
            [_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(didSendFuture:)])
                {
                    [obj didSendFuture:self];
                }
            }];
            
            _state = MJFutureStateSent;
            
            _thenBlock = nil;
            _value = nil;
            _error = nil;
            _customQueue = nil;
        }
        else
        {
            _state = MJFutureStateBlank;
        }
    }
}

@end