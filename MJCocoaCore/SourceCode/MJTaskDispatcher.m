//
// Copyright 2014 Mobile Jazz SL
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

#import "MJTaskDispatcher.h"

@interface MJTaskDispatcher ()

@end

@implementation MJTaskDispatcher
{
    NSMutableDictionary *_objects;
    
    NSMutableSet *_pendingTasks;
    NSMutableSet *_completedTasks;
    NSMutableSet *_failedTasks;
    
    NSHashTable *_observers;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _pendingTasks = [NSMutableSet set];
        _completedTasks = [NSMutableSet set];
        _failedTasks = [NSMutableSet set];
        
        _objects = [NSMutableDictionary dictionary];
        
        _observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark Public Methods

- (NSUInteger)count
{
    return _pendingTasks.count;
}

- (void)startTaskWithKey:(NSString*)key
{
    @synchronized(self)
    {
        [_pendingTasks addObject:key];
    }
}

- (void)completeTaskWithKey:(NSString*)key object:(id)object succeed:(BOOL)succeed
{
    @synchronized(self)
    {
        [_pendingTasks removeObject:key];
        
        if (succeed)
            [_completedTasks addObject:key];
        else
            [_failedTasks addObject:key];
        
        if (object)
            [_objects setObject:object forKey:key];
        
        [self mjz_checkTaskDispatchCompletion];
    }
}

- (void)completeAllPendingTasks
{
    @synchronized(self)
    {
        [_pendingTasks.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_completedTasks addObject:obj];
        }];
        [_pendingTasks removeAllObjects];
        
        [self mjz_checkTaskDispatchCompletion];
    }
}

- (void)failAllPendingTasks
{
    @synchronized(self)
    {
        [_pendingTasks.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_failedTasks addObject:obj];
        }];
        [_pendingTasks removeAllObjects];
        
        [self mjz_checkTaskDispatchCompletion];
    }
}

- (void)addObserver:(id <MJTaskDispatcherObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id <MJTaskDispatcherObserver>)observer
{
    [_observers removeObject:observer];
}

#pragma mark Private Methods

- (void)mjz_checkTaskDispatchCompletion
{
    @synchronized(self)
    {
        if (_pendingTasks.count == 0)
        {
            NSSet *completedTasks = [_completedTasks copy];
            NSSet *failedTasks = [_failedTasks copy];
            NSDictionary *objects = [_objects copy];
            
            [_observers.allObjects enumerateObjectsUsingBlock:^(id<MJTaskDispatcherObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(dispatcher:didCompleteTasks:failedTasks:objects:)])
                    [obj dispatcher:self didCompleteTasks:completedTasks failedTasks:failedTasks objects:objects];
                
                if ([obj respondsToSelector:@selector(dispatcher:didFailTasks:objects:)])
                    [obj dispatcher:self didFailTasks:failedTasks objects:objects];
                
                if ([obj respondsToSelector:@selector(dispatcher:didCompleteTasks:objects:)])
                    [obj dispatcher:self didCompleteTasks:completedTasks objects:objects];
            }];
        }
    }
}

@end
