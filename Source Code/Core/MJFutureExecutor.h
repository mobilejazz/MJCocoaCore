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

@interface MJFutureExecutor <T> : NSObject <MJFutureObserver>

- (id)initWithQueue:(dispatch_queue_t)queue;

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

@property (nonatomic, assign, readonly) BOOL isExecuting;

- (void)execute:(void (^)())block;

- (void)complete;
- (void)completeWithAllFutures:(NSArray <MJFuture <T> *> *)futures;
- (void)completeWithAnyFuture:(NSArray <MJFuture <T> *> *)futures;

@end
