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

@protocol MJObjectStackIdentity;

/**
 * An object stack.
 **/
@interface MJObjectStack : NSObject

/** *************************************************** **
 * @name Managing the Stack
 ** *************************************************** **/

- (void)push:(nonnull id <MJObjectStackIdentity>)object;

- (void)pop;

- (nullable id <MJObjectStackIdentity>)top;

- (void)remove:(nonnull id <MJObjectStackIdentity>)object;

- (BOOL)isTop:(nonnull id <MJObjectStackIdentity>)object;

- (BOOL)contains:(nonnull id <MJObjectStackIdentity>)object;

@end

/**
 * Objects must implement this protocol.
 **/
@protocol MJObjectStackIdentity <NSObject>

@required

/**
 * An unique string identified the object.
 **/
- (nonnull NSString *)objectStackIdentity;

@end

@interface NSString (MJObjectStack) <MJObjectStackIdentity>

@end

@interface NSNumber (MJObjectStack) <MJObjectStackIdentity>

@end
