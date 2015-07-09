//
//  DBBusStopFetchOperationTests.m
//  DBus
//
//  Created by Paolo Coronati on 06/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "DBBusStopFetchOperation.h"
#import "DBBusStop.h"
#import "DBOperation_Private.h"

@interface DBBusStopFetchOperationTests : XCTestCase

@end

@implementation DBBusStopFetchOperationTests{
    NSData * _stopsData;
    NSOperationQueue * _queue;
}

- (NSString *)dataPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return  [[paths objectAtIndex:0] stringByAppendingPathComponent:@"stopsData"];
}

- (void)setUp {
    [super setUp];
    NSFileManager * m = [NSFileManager defaultManager];
    if (![m fileExistsAtPath:[self dataPath]]){
        DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] init];
        _stopsData = [op downloadData];
        XCTAssertNotNil(_stopsData, @"Could not download data from the web");
        [_stopsData writeToFile:[self dataPath] atomically:YES];
    }
    else{
        _stopsData = [NSData dataWithContentsOfFile:[self dataPath]];
        XCTAssertNotNil(_stopsData, @"Could not read data from file");
    }
    _queue = [[NSOperationQueue alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test00testEmptyData {
    // This is an example of a functional test case.
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = [NSData data];
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)test01testNilData {
    // This is an example of a functional test case.
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = nil;
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)test02corruptedJSON {
    
    NSString * s = @"{adsònvadfvfdvsfionvsidf}";
    
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test03emptyRoot {
    
    NSDictionary * root = @{};
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = [NSJSONSerialization dataWithJSONObject:root options:0 error:nil];
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test04emptyPoints {
    
    NSDictionary * root = @{@"points": @""};
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = [NSJSONSerialization dataWithJSONObject:root options:0 error:nil];
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    NSDictionary * root2 = @{@"points": @[]};
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op2 = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e2 fulfill];
    }];
    op2.data = [NSJSONSerialization dataWithJSONObject:root2 options:0 error:nil];
    
    [_queue addOperation:op2];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)test05malformedPoints{
    NSDictionary * root = @{@"points": @[@""]};
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e1 fulfill];
    }];
    op.data = [NSJSONSerialization dataWithJSONObject:root options:0 error:nil];
    
    [_queue addOperation:op];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    NSDictionary * root2 = @{@"points": @[@{}]};
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op2 = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 0);
        [e2 fulfill];
    }];
    op2.data = [NSJSONSerialization dataWithJSONObject:root2 options:0 error:nil];
    
    [_queue addOperation:op2];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    NSDictionary * root3 = @{@"points": @[@{@"lat" : @1.1, @"lng":@3.3, @"address" : @"add", @"stopnumber" : @1234}]};
    
    XCTestExpectation * e3 = [self expectationWithDescription:@"first"];
    DBBusStopFetchOperation * op3 = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
        XCTAssertEqual(results.count, 1);
        DBBusStop * stop = [results objectAtIndex:0];
        XCTAssertEqual(1234, stop.stopNumber);
        XCTAssertEqualObjects(@"add", stop.address);
        XCTAssertEqual(NO, stop.favorite);
        [e3 fulfill];
    }];
    op3.data = [NSJSONSerialization dataWithJSONObject:root3 options:0 error:nil];
    
    [_queue addOperation:op3];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end