//
//  DBBusStopRealTimeOperationTests.m
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "DBBusStopRealTimeOperation.h"
#import "DBBusStopRealTimeOperation_Private.h"
#import "DBRealTimeStop.h"

@interface DBBusStopRealTimeOperationTests : XCTestCase

@end

@implementation DBBusStopRealTimeOperationTests{
    NSOperationQueue * _queue;
}

- (void)setUp{
    _queue = [[NSOperationQueue alloc] init];
}

- (void)test00noData{
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"e1"];
    
    DBBusStopRealTimeOperationHandler handler = ^(DBRealTimeStop * stop){
        XCTAssertEqual(0, [stop.buses count]);
        XCTAssertEqual(1666, stop.stopNumber);
        [e1 fulfill];
    };
    
    
    DBBusStopRealTimeOperation * op = [[DBBusStopRealTimeOperation alloc] initWithStopNumber:1666
                                                                                     handler:handler];
    op.data = nil;
    [_queue addOperation:op];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test01wrongData{
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"e1"];
    
    DBBusStopRealTimeOperationHandler handler = ^(DBRealTimeStop * stop){
        XCTAssertEqual(0, [stop.buses count]);
        XCTAssertEqual(1666, stop.stopNumber);
        [e1 fulfill];
    };
    
    DBBusStopRealTimeOperation * op = [[DBBusStopRealTimeOperation alloc] initWithStopNumber:1666
                                                                                     handler:handler];
    op.data = [@"dfkdsnfòasdnfansdfionads" dataUsingEncoding:NSUTF8StringEncoding];
    [_queue addOperation:op];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test02noTable{

    XCTestExpectation * e1 = [self expectationWithDescription:@"e1"];
    
    DBBusStopRealTimeOperationHandler handler = ^(DBRealTimeStop * stop){
        XCTAssertEqual(0, [stop.buses count]);
        XCTAssertEqual(1666, stop.stopNumber);
        [e1 fulfill];
    };
    
    DBBusStopRealTimeOperation * op = [[DBBusStopRealTimeOperation alloc] initWithStopNumber:1666
                                                                                     handler:handler];
    NSString * html = @"<html><head></head><body><table id=\"rtpi-results\"></table></body></html>";
    op.data = [html dataUsingEncoding:NSUTF8StringEncoding];
    [_queue addOperation:op];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}




@end