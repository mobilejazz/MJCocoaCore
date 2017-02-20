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

#import "MJDRealmCacheService.h"

@interface MJDRealmCacheService ()

@property (nonatomic, strong, readwrite) MJDRealmFactory *realmFactory;

@end

@implementation MJDRealmCacheService

- (instancetype)initWithRealmFactory:(MJDRealmFactory*)realmFactory
{
    self = [super init];
    if (self)
    {
        _realmFactory = realmFactory;
    }
    return self;
}

- (void)read:(void (^)(RLMRealm *realm))block
{
    RLMRealm *realm = [_realmFactory realmInstance];
    block(realm);
}

- (NSError*)write:(void (^)(RLMRealm *realm))block
{
    NSError *error = nil;
    RLMRealm *realm = [_realmFactory realmInstance];
    
    [realm transactionWithBlock:^{
        block(realm);
    } error:&error];
    
    if (!error)
    {
        [realm refresh];
    }
    
    return error;
}

@end
