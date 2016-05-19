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

#import "NSData+AESKey.h"

@implementation NSData (AESKey)

- (NSData*)aes_encryptValue:(NSData*)value
{
    return [value aes_encrypt:self withPadding:kCCOptionPKCS7Padding];
}

- (NSData*)aes_encryptValue:(NSData*)value usingPadding:(CCOptions)options
{
    return [value aes_encrypt:self withPadding:options];
}

- (NSData*)aes_decryptValue:(NSData*)value
{
    return [value aes_decrypt:self withPadding:kCCOptionPKCS7Padding];
}

- (NSData*)aes_decryptValue:(NSData*)value usingPadding:(CCOptions)options
{
    return [value aes_decrypt:self withPadding:options];
}

@end
