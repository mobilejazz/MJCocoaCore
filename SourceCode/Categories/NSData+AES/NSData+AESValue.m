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

#import "NSData+AESValue.h"

@implementation NSData (AESValue)

- (NSData*)aes_encryptWithKey:(NSData*)key
{
    return [self aes_encrypt:key withPadding:kCCOptionPKCS7Padding];
}

- (NSData*)aes_encryptWithKey:(NSData*)key usingPadding:(CCOptions)options
{
    return [self aes_encrypt:key withPadding:options];
}

- (NSData*)aes_decryptWithKey:(NSData*)key
{
    return [self aes_decrypt:key withPadding:kCCOptionPKCS7Padding];
}

- (NSData*)aes_decryptWithKey:(NSData*)key usingPadding:(CCOptions)options
{
    return [self aes_decrypt:key withPadding:options];
}

@end
