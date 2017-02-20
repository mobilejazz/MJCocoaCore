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
    MJFutureStateWontHappen,
};

@protocol MJFutureObserver;

/**
 * Future promise object.
 **/
@interface MJFuture <T> : NSObject

+ (MJFuture <T>*)emptyFuture;
+ (MJFuture <T>*)immediateFuture:(T)value;

@property (nonatomic, strong) dispatch_queue_t returnQueue;

@property (nonatomic, assign, readonly) MJFutureState state;

- (void)setValue:(T)value;
- (void)setError:(NSError*)error;
- (void)wontHappen;

- (void)then:(void (^)(T object, NSError *error))block;
- (void)then:(void (^)(T object, NSError *))block inQueue:(dispatch_queue_t)queue;

- (void)addObserver:(id <MJFutureObserver>)observer;
- (void)removeObserver:(id <MJFutureObserver>)observer;

@end

/**
 * Observer object.
 * @discussion Observer methods may be called from background threads.
 **/
@protocol MJFutureObserver <NSObject>

@optional

- (void)future:(MJFuture *)future didSetValue:(id)value;
- (void)future:(MJFuture *)future didSetError:(NSError*)error;
- (void)wontHappenFuture:(MJFuture*)future;
- (void)didSendFuture:(MJFuture*)future;

@end
