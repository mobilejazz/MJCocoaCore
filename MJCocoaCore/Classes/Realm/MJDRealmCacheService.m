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
#import "MJErrorCodes.h"

NSString *const MJDRealmCacheServiceDidCloseTransactionNotification = @"MJDRealmCacheServiceDidCloseTransactionNotification";

@interface MJDRealmCacheService ()

@property (nonatomic, strong, readwrite) MJDRealmFactory *realmFactory;

@end

@implementation MJDRealmCacheService

- (instancetype)initWithRealmFactory:(MJDRealmFactory *)realmFactory
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

- (NSError *)write:(void (^)(RLMRealm *realm))block
{
    NSError *error = nil;
    RLMRealm *realm = [_realmFactory realmInstance];

    BOOL shouldCommitTransaction = NO;

    if (![realm inWriteTransaction])
    {
        shouldCommitTransaction = YES;
        [realm beginWriteTransaction];
    }

    @try
    {
        block(realm);

        if (shouldCommitTransaction)
        {
            [realm commitWriteTransaction];
            [realm refresh];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MJDRealmCacheServiceDidCloseTransactionNotification object:nil userInfo:nil];
        }
    }
    @catch (NSException *exception)
    {
        if (shouldCommitTransaction)
        {
            [realm cancelWriteTransaction];

            error = [NSError errorWithDomain:MJErrorDomainRealmStorage code:MJErrorCodeTransactionFailed userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
        }
        else
        {
            [[exception copy] raise];
        }
    }

    return error;
}

@end

@implementation MJDRealmCacheService (MJFuture)

- (MJFuture*)ft_read:(id (^)(RLMRealm *realm))block
{
    MJFuture *future = [MJFuture emptyFuture];
    [self read:^(RLMRealm *realm) {
        id value = block(realm);
        [future setValue:value];
    }];
    return future;
}

- (MJFuture*)ft_write:(id (^)(RLMRealm *realm))block
{
    MJFuture *future = [MJFuture emptyFuture];
    __block id value = nil;
    NSError *error = [self write:^(RLMRealm *realm) {
        value = block(realm);
    }];
    [future setValue:value error:error];
    return future;
}

@end
