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

#import "NSData+SHA.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const NSDataSHAErrorDomain   = @"com.mobilejazz.NSData+SHA";

NSInteger const NSDataSHA1ErrorCode     = 1;
NSInteger const NSDataSHA256ErrorCode   = 2;

@implementation NSData (SHA)

- (NSData*)sha_SHA1
{
    return [self sha_SHA1WithError:nil];
}

- (NSData*)sha_SHA1WithError:(NSError**)error
{
    NSMutableData *md = [NSMutableData dataWithLength:16];
    unsigned char *result = [md mutableBytes];
    if (result != CC_SHA1(self.bytes, (CC_LONG)self.length, result))
    {
        if (error)
            *error = [NSError errorWithDomain:NSDataSHAErrorDomain code:NSDataSHA1ErrorCode userInfo:nil];
    }
    return md;
}

- (NSData*)sha_SHA256
{
    return [self sha_SHA256WithError:nil];
}

- (NSData*)sha_SHA256WithError:(NSError**)error
{
    NSMutableData *md = [NSMutableData dataWithLength:32];
    unsigned char *result = [md mutableBytes];
    if (result != CC_SHA256(self.bytes, (CC_LONG)self.length, result))
    {
        if (error)
            *error = [NSError errorWithDomain:NSDataSHAErrorDomain code:NSDataSHA256ErrorCode userInfo:nil];
    }
    return md;
}


@end
