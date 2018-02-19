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
#import "MJFutureHub.h"

NSString *const MJFutureValueNotAvailableException = @"MJFutureValueNotAvailableException";
NSString *const MJFutureErrorKey = @"MJFutureErrorKey";

#define MJFutureDuplicateInvocationException(method) [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"MJFuture doesn't allow calling twice the method <%@>.", NSStringFromSelector(@selector(method))] userInfo:nil]

#define MJFutureAlreadySentException [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Future already sent." userInfo:nil]

@interface MJFuture ()

@end

static dispatch_queue_t _defaultReturnQueue = nil;

@implementation MJFuture
{
    id _value;
    id _error;
    BOOL _isValueNil;
    
    void (^_success)(id value);
    void (^_failure)(NSError *error);
    
    void (^ _Nullable _onSetBlock)(_Nullable id __strong * _Nonnull, NSError * _Nullable __strong * _Nonnull );
    
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
    
    NSHashTable <id <MJFutureObserver>> *_observers;
}

+ (MJFuture *)emptyFuture
{
    MJFuture *future = [[MJFuture alloc] initReactive:NO];
    return future;
}

+ (MJFuture *)reactiveFuture
{
    MJFuture *future = [[MJFuture alloc] initReactive:YES];
    return future;
}

+ (MJFuture *)immediateFuture:(id)value
{
    MJFuture *future = [MJFuture emptyFuture];
    [future setValue:value];
    return future;
}

+ (MJFuture *)futureWithError:(NSError *)error
{
    MJFuture *future = [MJFuture emptyFuture];
    [future setError:error];
    return future;
}

+ (MJFuture *)futureWithFuture:(MJFuture *)future
{
    MJFuture *newFuture = [[MJFuture alloc] initReactive:future.reactive];
    [newFuture setFuture:future];
    return newFuture;
}

- (instancetype)init
{
    return [self initReactive:NO];
}

- (instancetype)initReactive:(BOOL)reactive
{
    self = [super init];
    if (self)
    {
        _reactive = reactive;
        _state = MJFutureStateBlank;
        _observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

+ (void)initialize
{
    [super initialize];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultReturnQueue = nil;
    });
}

+ (void)setDefaultReturnQueue:(dispatch_queue_t _Nonnull)queue
{
    _defaultReturnQueue = queue;
}

- (void)mimic:(MJFuture*)future
{
    _reactive = future.reactive;
}

- (void)setValue:(id)value
{
    @synchronized (self)
    {
        if (!_reactive)
        {
            if (_value || _isValueNil)
                [MJFutureDuplicateInvocationException(setValue:) raise];
        }
        
        if (value == nil)
            _isValueNil = YES;
        _value = value;
        _error = nil;
        
        [_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
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
        if (!_reactive)
        {
            if (_error)
                [MJFutureDuplicateInvocationException(setError:) raise];
        }
        
        if (error)
        {
            _error = error;
            _value = nil;
            _isValueNil = NO;
            
            [_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj respondsToSelector:@selector(future:didSetError:)])
                {
                    [obj future:self didSetError:error];
                }
            }];
            
            [self mjz_update];
        }
        else
        {
            NSLog(@"WARNING: Error set in MJFuture with nil value. This is a warning message, nothing is going to happen.");
        }
    }
}

- (void)setValue:(id)value error:(NSError *)error
{
    if (error)
    {
        [self setError:error];
    }
    else
    {
        [self setValue:value];
    }
}

- (void)setFuture:(MJFuture *)future
{
    [[future success:^(id  _Nullable value) {
        [self setValue:value];
    }] failure:^(NSError * _Nonnull error) {
        [self setError:error];
    }];
}

- (void)onSet:(void (^)(id __strong *, NSError * __strong *))block
{
    _onSetBlock = block;
}

- (MJFuture*)inQueue:(dispatch_queue_t)queue
{
    _queue = queue;
    return self;
}

- (MJFuture*)inMainQueue
{
    return [self inQueue:dispatch_get_main_queue()];
}

- (void)then:(void (^)(id value, NSError *error))block
{
    @synchronized (self)
    {
        if (!_reactive)
        {
            if (_success || _failure)
                [MJFutureDuplicateInvocationException(then:) raise];
        } 
        _success = ^(id value) {
            block(value, nil);
        };
        _failure = ^(NSError *error) {
            block(nil, error);
        };
        [self mjz_update];
    }
}

- (MJFuture *)success:(void (^)(id value))success
{
    if (_success)
    {
        void (^oldSuccess)(id) = _success;
        _success = nil;
        MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
        [future setFuture:self];
        [future success:^(id value) {
            oldSuccess(value);
            success(value);
        }];
        return future;
    }
    
    @synchronized (self)
    {
        _success = success;
        [self mjz_update];
    }
    
    return self;
}

- (MJFuture *)failure:( void (^)(NSError *error))failure
{
    if (_failure)
    {
        void (^oldFailure)(id) = _failure;
        _failure = nil;
        MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
        [future setFuture:self];
        [future failure:^(NSError *error) {
            oldFailure(error);
            failure(error);
        }];
        return future;
    }
    
    @synchronized (self)
    {
        _failure = failure;
        [self mjz_update];
    }
    
    return self;
}

- (void)complete
{
    if (_state != MJFutureStateSent)
    {
        _state = MJFutureStateSent;
        _success = nil;
        _failure = nil;
        if (_semaphore != nil)
        {
            dispatch_semaphore_signal(_semaphore);
            _semaphore = nil;
        }
    }
}

- (_Nullable id)value
{
    NSError *error = nil;
    id value = [self valueWithError:&error];
    
    if (error)
    {
        NSException *exception = [NSException exceptionWithName:MJFutureValueNotAvailableException
                                                         reason:@"Value is not available."
                                                       userInfo:@{MJFutureErrorKey: error}];
        @throw exception;
    }
    else
    {
        return value;
    }
}

- (_Nullable id)valueWithError:(NSError * _Nullable __strong * _Nullable)error
{
    if (_state == MJFutureStateWaitingBlock)
    {
        if (_error)
        {
            if (error)
                *error = _error;
        }
        else // if (_value || _isValueNil)
        {
            if (!_reactive)
            {
                _state = MJFutureStateSent;
            }
            return _value;
        }
    }
    else if (_state == MJFutureStateBlank)
    {
        if (_semaphore == nil)
            _semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        _semaphore = nil;
        
        return [self value];
    }
    else
    {
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                         reason:@"Misusage of future"
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
}

- (void)removeObserver:(id <MJFutureObserver>)observer
{
    [_observers removeObject:observer];
}

- (MJFutureHub *)hub
{
    if (_hub)
        return _hub;
    
    _hub = [MJFutureHub hubWithFuture:self];
    return _hub;
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
        
        if (_value || _error || _isValueNil)
        {
            _state = MJFutureStateWaitingBlock;
            
            if (_onSetBlock) {
                _onSetBlock(&_value, &_error);
            }
            
            if (_semaphore != nil)
                dispatch_semaphore_signal(_semaphore);
        }
        else if (_success || _failure)
        {
            _state = MJFutureStateWaitingValueOrError;
        }
    }
    else if (_state == MJFutureStateWaitingBlock)
    {
        if ((_success && (_value || _isValueNil)) || (_failure && _error))
        {
            [self mjz_send];
            if (!_reactive)
            {
                _state = MJFutureStateSent;
            }
        }
    }
    else if (_state == MJFutureStateWaitingValueOrError)
    {
        if ((_value || _isValueNil) || _error)
        {
            
            if (_onSetBlock) {
                _onSetBlock(&_value, &_error);
            }
            
            if (_semaphore != nil)
                dispatch_semaphore_signal(_semaphore);
            
            [self mjz_send];
            
            if (!_reactive)
            {
                _state = MJFutureStateSent;
            }
        }
    }
}

- (void)mjz_send
{
    void (^success)(id) = _success;
    void (^failure)(id) = _failure;
    id value = _value;
    id error = _error;
    dispatch_queue_t queue = _queue ? _queue : _defaultReturnQueue;
    
    if (error)
    {
        if (queue)
            dispatch_async(queue, ^{ failure(error); });
        else
            failure(error);
    }
    else if (value)
    {
        if (queue)
            dispatch_async(queue, ^{ success(value); });
        else
            success(value);
    }
    
    [_observers.allObjects enumerateObjectsUsingBlock:^(id <MJFutureObserver> _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj respondsToSelector:@selector(didSendFuture:)])
        {
            [obj didSendFuture:self];
        }
    }];
    
    if (!_reactive)
    {
        _success = nil;
        _failure = nil;
        _value = nil;
        _error = nil;
        _onSetBlock = nil;
    }
}

@end

@implementation MJFuture (Functional)

- (MJFuture *)map:(id (^)(id))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id object, NSError * error) {
        if (object)
        {
            object = block(object);
        }
        [future setValue:object error:error];
    }];
    return future;
}

- (MJFuture *)mapError:(NSError* (^)(NSError*))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id object, NSError * error) {
        if (error)
        {
            error = block(error);
        }
        [future setValue:object error:error];
    }];
    return future;
}

- (MJFuture *)flatMap:(MJFuture * (^)(id))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id object, NSError * error) {
        if (error)
        {
            [future setError:error];
        }
        else
        {
            if (object)
                [future setFuture:block(object)];
            else
                [future setValue:nil];
        }
    }];
    return future;
}

- (MJFuture *)recover:(MJFuture <id> * (^)(NSError*))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id object, NSError * error) {
        if (error)
            [future setFuture:block(error)];
        else
            [future setValue:object];
    }];
    return future;
}

- (MJFuture *)filter:(NSError* (^)(id))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id object, NSError * error) {
        if (error)
        {
            [future setError:error];
        }
        else
        {
            NSError *error = block(object);
            if (error)
                [future setError:error];
            else
                [future setValue:object];
        }
    }];
    return future;
}

- (MJFuture *)andThen:(void (^)(id value, NSError * error))block
{
    MJFuture *future = [[MJFuture alloc] initReactive:self.reactive];
    [self then:^(id  _Nullable value, NSError * _Nullable error) {
        [future setValue:value error:error];
    }];
    return future;
}

@end

