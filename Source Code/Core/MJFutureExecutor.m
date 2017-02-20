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

#import "MJFutureExecutor.h"

@interface MJFutureExecutorItem : NSObject

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) NSInteger futureCounter;

- (void)wait;
- (void)complete;

@end

@implementation MJFutureExecutorItem

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _semaphore = dispatch_semaphore_create(0);
        _futureCounter = 0;
    }
    return self;
}

- (void)wait
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)complete
{
    dispatch_semaphore_signal(_semaphore);
}

@end

@interface MJFutureExecutor ()

@property (nonatomic, strong, readwrite) dispatch_queue_t queue;

@end

@implementation MJFutureExecutor
{
    MJFutureExecutorItem *_currentItem;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        _queue = queue;
    }
    return self;
}

- (void)execute:(void (^)())block
{
    MJFutureExecutorItem *item = [[MJFutureExecutorItem alloc] init];
    
    dispatch_async(self.queue, ^{
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        _currentItem = item;
        block();
        [_currentItem wait];
        _currentItem = nil;
        
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = NO;
        [self didChangeValueForKey:@"isExecuting"];
    });
}

- (void)complete
{
    [_currentItem complete];
}

- (void)completeWithAllFutures:(NSArray <MJFuture <id> *> *)futures
{
    _currentItem.futureCounter += futures.count; // All futures must finish to complete
    
    [futures enumerateObjectsUsingBlock:^(MJFuture <id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addObserver:self];
    }];
}

- (void)completeWithAnyFuture:(NSArray <MJFuture <id> *> *)futures
{
    _currentItem.futureCounter = 1; // When finishing any future, will complete
    
    [futures enumerateObjectsUsingBlock:^(MJFuture <id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addObserver:self];
    }];
}

#pragma mark - Protocols
#pragma mark MJFutureObserver

- (void)future:(MJFuture *)future didSetValue:(id)value
{
    _currentItem.futureCounter--;
    
    if (_currentItem.futureCounter == 0)
    {
        [self complete];
    }
}

- (void)future:(MJFuture *)future didSetError:(NSError *)error
{
    _currentItem.futureCounter--;
    
    if (_currentItem.futureCounter == 0)
    {
        [self complete];
    }
}

- (void)wontHappenFuture:(MJFuture *)future
{
    _currentItem.futureCounter--;
    
    if (_currentItem.futureCounter == 0)
    {
        [self complete];
    }
}

@end
