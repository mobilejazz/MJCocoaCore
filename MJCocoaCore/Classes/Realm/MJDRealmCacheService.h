//
// Copyright 2016 Mobile Jazz SL
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

#import <Realm/Realm.h>

#import "MJDRealmFactory.h"

extern NSString *const MJDRealmCacheServiceDidCloseTransactionNotification;

/**
 * Realm cache service.
 **/
@interface MJDRealmCacheService : NSObject

/**
 * Default initializer.
 * @param realmFactory The realm factory.
 * @return The initialized instance.
 **/
- (instancetype)initWithRealmFactory:(MJDRealmFactory*)realmFactory;

/**
 * Provides a realm scope for read only operations.
 * @param block The block that provides a realm instance.
 **/
- (void)read:(void (^)(RLMRealm *realm))block;

/**
 * Provides a realm scope for write only operations.
 * @param block The block that provides a realm instance.
 * @discussion This method generates a realm transaction and manages it automatically.
 **/
- (NSError*)write:(void (^)(RLMRealm *realm))block;

@end
