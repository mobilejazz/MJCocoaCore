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

#import "NSData+AES.h"

#import "NSDataAESCipher.h"

@implementation NSData (AES)

- (NSData*)aes_encrypt:(NSData*)key
{
    return [self aes_encrypt:key withInitial:nil];
}

- (NSData*)aes_encryptWithString:(NSString*)key
{
    return [self aes_encrypt:[key dataUsingEncoding:NSUTF8StringEncoding] withInitial:nil];
}

- (NSData*)aes_encrypt:(NSData*)key withInitial:(NSData*)iv
{
    return [self aes_encrypt:key withInitial:iv andPadding:kCCOptionPKCS7Padding];
}

- (NSData*)aes_encrypt:(NSData*)key withPadding:(CCOptions)options
{
    return [self aes_encrypt:key withInitial:nil andPadding:options];
}

- (NSData*)aes_encrypt:(NSData*)key withInitial:(NSData*)iv andPadding:(CCOptions)options
{
    return [NSDataAESCipher cipherWithkey:key
                                    value:self
                                       iv:iv
                                operation:kCCEncrypt
                                  options:options
                                   output:nil
                                    error:nil];
}

- (NSData*)aes_decrypt:(NSData*)key
{
    return [self aes_decrypt:key withInitial:nil];
}

- (NSData*)aes_decryptWithString:(NSString*)key
{
    return [self aes_decrypt:[key dataUsingEncoding:NSUTF8StringEncoding] withInitial:nil];
}

- (NSData*)aes_decrypt:(NSData*)key withInitial:(NSData*)iv
{
    return [self aes_decrypt:key withInitial:iv andPadding:kCCOptionPKCS7Padding];
}

- (NSData *)aes_decrypt:(NSData *)key withPadding:(CCOptions)options
{
    return [self aes_decrypt:key withInitial:nil andPadding:options];
}

- (NSData*)aes_decrypt:(NSData*)key withInitial:(NSData*)iv andPadding:(CCOptions)options
{
    return [NSDataAESCipher cipherWithkey:key
                                    value:self
                                       iv:nil
                                operation:kCCDecrypt
                                  options:options
                                   output:nil
                                    error:nil];
}

@end
