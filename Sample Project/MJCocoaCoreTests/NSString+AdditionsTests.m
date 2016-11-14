//
//  NSString+AdditionsTests.m
//  MJCocoaCore
//
//  Created by Diego Freniche Brito on 11/11/16.
//  Copyright © 2016 MobileJazz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Additions.h"

static const NSString *testString = @"This is really awesome I mean awesome ++";

@interface NSString_AdditionsTests : XCTestCase

@end

@implementation NSString_AdditionsTests


- (void)test_add_words {
    NSArray <NSString *> *words = [testString add_words];
    NSArray <NSString *> *result = @[@"This",  @"is", @"really",  @"awesome",  @"I",  @"mean",  @"awesome",  @"++"];
    
    XCTAssertEqualObjects(words, result);
}

- (void)test_add_first_word {
    NSString *sut = [testString add_firstWord];
    
    XCTAssertEqualObjects(sut, @"This");
}

- (void)test_add_last_word {
    NSString *sut = [testString add_lastWord];
    
    XCTAssertEqualObjects(sut, @"++");
}

- (void)test_add_string_by_deleting_first_word {
    NSString *sut = [testString add_stringByDeletingFirstWord];
    
    XCTAssertEqualObjects(sut, @"is really awesome I mean awesome ++");
}

- (void)test_add_random_string {
    NSString *sut = [NSString add_randomString];
    
    XCTAssertNotNil(sut);
    XCTAssertTrue(sut.length >= 10);
}


- (void)test_add_random_string_with_length {
    NSString *sut = [NSString add_randomStringWithLength:10];
    
    XCTAssertEqual(sut.length, 10);
}

- (void)test_add_unique_string {
    NSString *sut = [NSString add_uniqueString];
    
    XCTAssertNotNil(sut);
    XCTAssertTrue(sut.length > 0);
}


- (void)test_add_string_with_components {
    NSArray <NSString *> *components = @[@"This",  @"is", @"really",  @"awesome",  @"I",  @"mean",  @"awesome",  @"++"];
    
    NSString *sut = [NSString add_stringWithComponents:components joinedWithString:@"-"];
    
    XCTAssertEqualObjects(sut, @"This-is-really-awesome-I-mean-awesome-++");

}

@end
