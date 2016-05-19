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

#import "NSDataAESCipher.h"
#import "NSMutableData+AES.h"

@implementation NSMutableData (AES)

- (void)aes_encryptInPlace:(NSData*)key
{
    [self aes_encryptInPlace:key withPadding:kCCOptionPKCS7Padding];
}

- (void)aes_encryptInPlace:(NSData*)key withPadding:(CCOptions)options
{
    NSData *data = [NSDataAESCipher cipherWithkey:key
                                            value:self
                                               iv:nil
                                        operation:kCCEncrypt
                                          options:options
                                           output:nil
                                            error:nil];
    [self setData:data];
}

- (void)aes_decryptInPlace:(NSData*)key
{
    [self aes_decryptInPlace:key withPadding:kCCOptionPKCS7Padding];
}

- (void)aes_decryptInPlace:(NSData*)key withPadding:(CCOptions)options
{
    NSData *data = [NSDataAESCipher cipherWithkey:key
                                            value:self
                                               iv:nil
                                        operation:kCCDecrypt
                                          options:options
                                           output:nil
                                            error:nil];
    
    [self setData:data];
}

@end
