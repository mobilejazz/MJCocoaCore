//
//  NSDataAESCipher.m
//  MJ-iOS-Toolkit
//
//  Created by Joan Martin on 09/05/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import "NSDataAESCipher.h"

#import "NSData+SHA.h"

NSString * NSDataAESCipherErrorDomain = @"com.mobilejazz.NSDataAESCipher";

NSInteger const NSDataAESCipherUndefinedErrorCode       = 0;
NSInteger const NSDataAESCipherParamErrorCode           = kCCParamError;
NSInteger const NSDataAESCipherBufferTooSmallErrorCode  = kCCBufferTooSmall;
NSInteger const NSDataAESCipherMemoryFailureErrorCode   = kCCMemoryFailure;
NSInteger const NSDataAESCipherAlignmentErrorCode       = kCCAlignmentError;
NSInteger const NSDataAESCipherDecodeErrorCode          = kCCDecodeError;
NSInteger const NSDataAESCipherCUnimplementedErrorCode  = kCCUnimplemented;

@implementation NSDataAESCipher

+ (NSData*)cipherWithkey:(NSData*)key
                   value:(NSData*)value
                      iv:(NSData*)iv
               operation:(CCOperation)operation
                 options:(CCOptions)options
                  output:(NSMutableData*)output
                   error:(NSError**)error
{
    if (kCCKeySizeAES256 != key.length)
    {
        // SHA256 the key unless it's already 256 bits.
        key = [key sha_SHA256];
    }
    
    NSUInteger len = value.length;
    NSUInteger capacity = (NSUInteger)(len / kCCBlockSizeAES128 + 1) * kCCBlockSizeAES128;
    NSMutableData *data;
    if (nil == output)
    {
        data = [NSMutableData dataWithLength:capacity];
    }
    else
    {
        data = output;
        if (data.length < capacity)
        {
            [data setLength:capacity];
        }
    }
    
    if (iv && kCCBlockSizeAES128 != iv.length)
    {
        // SHA1 the iv if provided.
        iv = [iv sha_SHA1];
    }
    else
    {
        iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];
    }
    
    const void *_iv = iv.bytes;
    
    size_t dataOutMoved;
    CCCryptorStatus ccStatus = CCCrypt(operation,
                                       kCCAlgorithmAES128,
                                       options,
                                       (const char*)key.bytes,
                                       key.length,
                                       _iv,
                                       (const void *)value.bytes,
                                       [value length],
                                       (void *)data.mutableBytes,
                                       capacity,
                                       &dataOutMoved
                                       );
    
    if (dataOutMoved < data.length)
    {
        [data setLength:dataOutMoved];
    }
    
    switch (ccStatus)
    {
        case kCCSuccess:
            return data;
            break;
            
        case kCCParamError:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherParamErrorCode userInfo:nil];
            break;
        case kCCBufferTooSmall:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherBufferTooSmallErrorCode userInfo:nil];
            break;
        case kCCMemoryFailure:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherMemoryFailureErrorCode userInfo:nil];
            break;
        case kCCAlignmentError:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherAlignmentErrorCode userInfo:nil];
            break;
        case kCCDecodeError:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherDecodeErrorCode userInfo:nil];
            break;
        case kCCUnimplemented:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherCUnimplementedErrorCode userInfo:nil];
            break;
        default:
            if (error)
                *error = [NSError errorWithDomain:NSDataAESCipherErrorDomain code:NSDataAESCipherUndefinedErrorCode userInfo:nil];
            break;
    }
    
    return nil;
}

@end
