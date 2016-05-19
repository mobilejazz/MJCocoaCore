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

#import <Foundation/Foundation.h>

@protocol MJTaskDispatcherObserver;

/**
 * A MJTaskDispatcher is an object that stores multiple task keys and once those are finished, notifies the observers.
 * This class is thread-safe.
 **/
@interface MJTaskDispatcher : NSObject

/**
 * Optionally, a completion block can be set in order to retain the block until called.
 **/
@property (nonatomic, strong) id completionBlock;

/** ************************************************************ **
 * @name Handling tasks
 ** ************************************************************ **/

/**
* The number of pending tasks.
* @return The number of pending tasks.
**/
- (NSUInteger)count;

/**
 * Defines a task start.
 * @param key   The key of the task that is starting. Cannot be nil.
 **/
- (void)startTaskWithKey:(NSString*)key;

/**
 * Mark a task as completed.
 * @param key       The key of the task to complete.
 * @param object    An associated object to the task.
 * @param succeed   An boolean flag indicating if the tasks has successfully finished.
 **/
- (void)completeTaskWithKey:(NSString*)key object:(id)object succeed:(BOOL)succeed;

/**
 * Mark all pending tasks as completed.
 **/
- (void)completeAllPendingTasks;

/**
 * Mark all pending tasks as failed.
 **/
- (void)failAllPendingTasks;

/** ************************************************************ **
 * @name Observation
 ** ************************************************************ **/

/**
 * Ads an observer.
 * @param observer An observer.
 **/
- (void)addObserver:(id <MJTaskDispatcherObserver>)observer;

/**
 * Removes an observer.
 * @param observer An observer.
 **/
- (void)removeObserver:(id <MJTaskDispatcherObserver>)observer;

@end

/**
 * The observer object protocol.
 **/
@protocol MJTaskDispatcherObserver <NSObject>

/** ************************************************************ **
 * @name Methods
 ** ************************************************************ **/

@optional

/**
 * Method called when all tasks have completed. 
 * @param dispatcher        The dispatcher object.
 * @param completedTasks    A dictionary containing the succeed task keys.
 * @param failedTasks       A dictionary containing the failed task keys.
 * @param objects           A dictionary containing the objects.
 **/
- (void)dispatcher:(MJTaskDispatcher*)dispatcher didCompleteTasks:(NSSet*)completedTasks failedTasks:(NSSet*)failedTasks objects:(NSDictionary*)objects;

/**
 * Method called when all tasks have completed.
 * @param dispatcher The dispatcher object.
 * @param tasks         A dictionary containing the succeed task keys.
 * @param objects       A dictionary containing the objects.
 * @discussion The failed tasks method will be called before the succeed tasks.
 **/
- (void)dispatcher:(MJTaskDispatcher *)dispatcher didCompleteTasks:(NSSet*)tasks objects:(NSDictionary*)objects;

/**
 * Method called when all tasks have completed.
 * @param dispatcher The dispatcher object.
 * @param tasks         A dictionary containing the failed task keys.
 * @param objects       A dictionary containing the objects.
 * @discussion The failed tasks method will be called before the succeed tasks.
 **/
- (void)dispatcher:(MJTaskDispatcher *)dispatcher didFailTasks:(NSSet*)tasks objects:(NSDictionary*)objects;;

@end
