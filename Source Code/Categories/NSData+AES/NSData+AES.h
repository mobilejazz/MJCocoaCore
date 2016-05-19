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

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

/**
 * NSData AES encryption category.
 **/
@interface NSData (AES)

/** *************************************************** **
 * @name Encrypt
 ** *************************************************** **/

- (NSData*)aes_encrypt:(NSData*)key;
- (NSData*)aes_encryptWithString:(NSString*)key;
- (NSData*)aes_encrypt:(NSData*)key withPadding:(CCOptions) options;
- (NSData*)aes_encrypt:(NSData*)key withInitial:(NSData*)iv;
- (NSData*)aes_encrypt:(NSData*)key withInitial:(NSData*)iv andPadding:(CCOptions)options;

/** *************************************************** **
 * @name Decrypt
 ** *************************************************** **/

- (NSData*)aes_decrypt:(NSData*)key;
- (NSData*)aes_decryptWithString:(NSString*)key;
- (NSData*)aes_decrypt:(NSData*)key withPadding:(CCOptions)options;
- (NSData*)aes_decrypt:(NSData*)key withInitial:(NSData*)iv;
- (NSData*)aes_decrypt:(NSData*)key withInitial:(NSData*)iv andPadding:(CCOptions)options;

@end
