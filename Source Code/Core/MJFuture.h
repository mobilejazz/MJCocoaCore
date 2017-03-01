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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MJFutureState)
{
	MJFutureStateBlank,
	MJFutureStateWaitingBlock,
	MJFutureStateWaitingValueOrError,
	MJFutureStateSent,
	MJFutureStateWontHappen
};

extern NSString * _Nonnull const MJFutureValueNotAvailableException;
extern NSString * _Nonnull const MJFutureErrorKey;

@protocol MJFutureObserver;

/**
 * Future promise object.
 **/
@interface MJFuture <T> : NSObject

#pragma mark - Creation

/**
 Create an empty future

 @return An empty future
 */
+ (MJFuture < T>* _Nonnull)emptyFuture;

/**
 Create an immediate future passing a value

 @param value The value to set to the future
 @return A future
 */
+ (MJFuture <T>* _Nonnull)immediateFuture:(_Nonnull T)value;

#pragma mark - Future lifecytle

/**
 The queue on which the completion block will be called
 */
@property (nonatomic, strong, readwrite) dispatch_queue_t _Nonnull returnQueue;

@property (nonatomic, assign, readonly) MJFutureState state;

#pragma mark - Future value management

/**
 Set the value on the future. If the future is ready, the *then* block will be called

 @param value A not null value
 */
- (void)setValue:(_Nonnull T)value;

/**
 Set an error on the future. If the future is ready, the *then* block will be called

 @param error A not null error object
 */
- (void)setError:(NSError * _Nonnull)error;

/**
 Cancel the future execution. This will block any future execution
 */
- (void)wontHappen;

#pragma mark - Future execution

/**
 Completion block executed when the future has value.
 By default this get called on the returnQueue.
 
 @param block The block to be executed, with the object or the error passed as parameter
 */
- (void)then:(void (^ _Nullable )(_Nullable T object, NSError *_Nullable error))block;

/**
 Completion block executed when the future has value.

 @param block The block to be executed, with the object or the error passed as parameter
 @param queue The queue on which the block will be caled
 */
- (void)then:(void (^_Nullable)(_Nullable T object, NSError *_Nullable error))block inQueue:(_Nullable dispatch_queue_t)queue;

/**
 Block the current thread until the value is obtained or return the value direclty if it is already availble.
 @return The future value.
 @discussion If error, this method returns nil and throws an exception.
 */
- (_Nullable T)value;

#pragma mark - Observer management

- (void)addObserver:(_Nonnull id <MJFutureObserver>)observer;
- (void)removeObserver:(_Nonnull id <MJFutureObserver>)observer;

@end

/**
 * Observer object.
 * @discussion Observer methods may be called from background threads.
 **/
@protocol MJFutureObserver <NSObject>

@optional

- (void)future:(MJFuture *_Nonnull)future didSetValue:(_Nonnull id)value;
- (void)future:(MJFuture *_Nonnull)future didSetError:(NSError *_Nonnull)error;
- (void)wontHappenFuture:(MJFuture *_Nonnull)future;
- (void)didSendFuture:(MJFuture *_Nonnull)future;

@end
