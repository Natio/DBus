//
//  DBBusStopFetchOperationTests.m
//  DBus
//
//  Created by Paolo Coronati on 06/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "DBSoapRealTimeBusStopOperation.h"
#import "DBBusStop.h"
#import "DBOperation_Private.h"

@interface DBSoapRealTimeBusStopOperationTests : XCTestCase

@end

@implementation DBSoapRealTimeBusStopOperationTests{
    NSOperationQueue * _queue;
}


- (void)setUp {
    [super setUp];
    _queue = [[NSOperationQueue alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test00realData{
    XCTestExpectation *e1 = [self expectationWithDescription:@"e1"];
    NSBundle * bundle = [NSBundle bundleForClass: [self class]];
    NSString * path = [bundle pathForResource:@"real_time_soap" ofType:@"xml"];
    DBSoapRealTimeBusStopOperation * soap = [[DBSoapRealTimeBusStopOperation alloc] initWithStopNumber:6 handler:^(DBRealTimeStop * stop){
        XCTAssertNotNil(stop);
        [e1 fulfill];
    }];
    soap.data = [NSData dataWithContentsOfFile:path];
    [_queue addOperation:soap];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end