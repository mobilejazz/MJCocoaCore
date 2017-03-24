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

#import "MJFuture.h"

/**
 * Batch a set of futures to handle them together.
 **/
@interface MJFutureBatch <T> : NSObject

/**
 * Creates a future batch from an array of futures.
 * @param futures The array of futures.
 **/
+ (MJFutureBatch*)batchFutures:(NSArray <MJFuture <T> *> *)futures;

/**
 * Default init method.
 * @param futures The array of futures.
 **/
- (instancetype)initWithFutures:(NSArray <MJFuture <T> *> *)futures;

/**
 * Then block that will be invoked for each future in the batch.
 * @param block The then block.
 **/
- (void)then:(void (^)(T object, NSError *error))block;

/**
 * Then block that will be invoked for each future in the batch.
 * @param block The then block.
 * @param completion A completion block called after all futures have finished. If any future contains an error, the first error received will be returned inside the block. An error == nil means that any future had an error.
 **/
- (void)then:(void (^)(T object, NSError *error))block completion:(void (^)(NSError *error))completion;

@end
