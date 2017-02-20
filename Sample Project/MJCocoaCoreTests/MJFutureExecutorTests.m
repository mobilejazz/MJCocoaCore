//
//  MJFutureExecutorTests.m
//  MJCocoaCore
//
//  Created by Joan Martin on 26/01/2017.
//  Copyright © 2017 MobileJazz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MJFuture.h"
#import "MJFutureExecutor.h"

@interface MJFutureExecutorTests : XCTestCase

@end

@implementation MJFutureExecutorTests
{
    MJFutureExecutor <NSString*> *_futureExecutor;
}

- (void)setUp
{
    [super setUp];
    
    dispatch_queue_t queue = dispatch_queue_create([@"com.mobilejazz.test" cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    _futureExecutor = [[MJFutureExecutor alloc] initWithQueue:queue];
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_multiple_execute_blocks
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"1"];
    
    __block NSInteger counter = 0;
    
    [_futureExecutor execute:^{
        XCTAssertEqual(counter, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ++counter;
            [_futureExecutor complete];
        });
    }];
    
    [_futureExecutor execute:^{
        XCTAssertEqual(counter, 1);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ++counter;
            [_futureExecutor complete];
        });
    }];
    
    [_futureExecutor execute:^{
        XCTAssertEqual(counter, 2);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ++counter;
            [_futureExecutor complete];
            [expectation fulfill];
        });
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_with_one_future
{
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"2"];
    
    MJFuture <NSString*> *future = [[MJFuture alloc] init];
    
    [_futureExecutor execute:^{
        [_futureExecutor completeWithAllFutures:@[future]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [future setValue:@"hello"];
        });
    }];
    
    [future then:^(NSString *object, NSError *error) {
        [expectation1 fulfill];
    }];
    
    [_futureExecutor execute:^{
        XCTAssertEqual(future.state, MJFutureStateSent);
        [expectation2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)test_with_all_futures
{
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"2"];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"3"];
    XCTestExpectation *expectation4 = [self expectationWithDescription:@"4"];
    
    MJFuture <NSString*> *future1 = [[MJFuture alloc] init];
    MJFuture <NSString*> *future2 = [[MJFuture alloc] init];
    MJFuture <NSString*> *future3 = [[MJFuture alloc] init];
    
    [_futureExecutor execute:^{
        [_futureExecutor completeWithAllFutures:@[future1, future2, future3]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [future1 setValue:@"hello"];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [future2 setValue:@"hello"];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.85 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [future3 setValue:@"hello"];
        });
    }];
    
    [future1 then:^(NSString *object, NSError *error) {
        [expectation1 fulfill];
    }];
    
    [future2 then:^(NSString *object, NSError *error) {
        [expectation2 fulfill];
    }];
    
    [future3 then:^(NSString *object, NSError *error) {
        [expectation3 fulfill];
    }];
    
    [_futureExecutor execute:^{
        XCTAssertEqual(future1.state, MJFutureStateSent);
        XCTAssertEqual(future2.state, MJFutureStateSent);
        XCTAssertEqual(future3.state, MJFutureStateSent);
        
        [expectation4 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
