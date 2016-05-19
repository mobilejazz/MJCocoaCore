//
// Copyright 2015 Mobile Jazz SL
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

/**
 * Interactor superclass.
 **/
@interface MJInteractor : NSObject

/**
 * The dispatch queue.
 **/
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

/**
 * Executes a block in a background queue.
 * @discussion A `begin` call must be in corresponded to a `end` call.
 **/
- (void)begin:(void (^)())block;

/**
 * Executes a block in the main queue.
 * @discussion A `begin` call must be in corresponded to a `end` call.
 **/
- (void)end:(void (^)())block;

/**
 * Set needs refresh method. This will flag the `refresh` property to YES until the end of the interactor.
 **/
- (void)setNeedsRefresh;

/**
 * A refresh flag.
 **/
@property (nonatomic, assign, readonly) BOOL refresh;

@end
