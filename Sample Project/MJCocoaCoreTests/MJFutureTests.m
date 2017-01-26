//
//  MJFutureTests.m
//  MJCocoaCore
//
//  Created by Joan Martin on 26/01/2017.
//  Copyright © 2017 MobileJazz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MJFuture.h"

@interface MJFutureTests : XCTestCase

@end

@implementation MJFutureTests
{
    MJFuture <NSString*> *_future;
}

- (void)setUp
{
    [super setUp];

     _future = [[MJFuture alloc] init];
}

- (void)tearDown
{
    _future = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_value_first_then_block
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future setValue:@"hola"];
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqualObjects(object, @"hola");
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_block_first_then_value
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqualObjects(object, @"hola");
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [_future setValue:@"hola"];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_value_first_then_block_with_delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future setValue:@"hola"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_future then:^(NSString *object, NSError *error) {
            XCTAssertEqualObjects(object, @"hola");
            XCTAssertNil(error);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)test_block_first_then_value_with_delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqualObjects(object, @"hola");
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_future setValue:@"hola"];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}


- (void)test_error_first_then_block
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future setError:[self mjz_fakeError]];
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqual(error, [self mjz_fakeError]);
        XCTAssertNil(object);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_block_first_then_error
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqual(error, [self mjz_fakeError]);
        XCTAssertNil(object);
        [expectation fulfill];
    }];
    [_future setError:[self mjz_fakeError]];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_error_first_then_block_with_delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future setError:[self mjz_fakeError]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_future then:^(NSString *object, NSError *error) {
            XCTAssertEqual(error, [self mjz_fakeError]);
            XCTAssertNil(object);
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)test_block_first_then_error_with_delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future then:^(NSString *object, NSError *error) {
        XCTAssertEqual(error, [self mjz_fakeError]);
        XCTAssertNil(object);
        [expectation fulfill];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_future setError:[self mjz_fakeError]];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)test_wont_happen
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    [_future then:^(NSString *object, NSError *error) {
        XCTFail();
    }];
    
    [_future wontHappen];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Private Methods

- (NSError*)mjz_fakeError
{
    static NSError *error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [NSError errorWithDomain:@"com.mobilejazz" code:1 userInfo:nil];
    });
    return error;
}


@end
