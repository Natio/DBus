//
//  DBStopsManagerTests.m
//  DBus
//
//  Created by Paolo Coronati on 06/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBDatabaseController.h"
#import <XCTest/XCTest.h>
#import "DBBusStop.h"
#import <CoreLocation/CoreLocation.h>
#import "DBStopsManager.h"

@interface DBStopsManager ()
- (instancetype)initWithDatabaseController:(DBDatabaseController *)controller;
@end

@interface DBStopsManagerTests : XCTestCase

@end

@implementation DBStopsManagerTests{
    NSString * _dbPath;
    CLLocation *_center;
}

+ (void)setUp{
    [DBStopsManager sharedInstance];
}


- (void)setUp {
    [super setUp];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test_db.sqlite"];
    NSLog(@"%@",_dbPath);
    NSFileManager * m = [NSFileManager defaultManager];
    if ([m fileExistsAtPath:_dbPath]){
        [m removeItemAtPath:_dbPath error:nil];
    }
    _center = [[CLLocation alloc] initWithLatitude:53.349958 longitude:-6.280830];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)loadData:(DBDatabaseController *)c{
    CLLocation * n1 = [[CLLocation alloc] initWithLatitude:53.349881 longitude:-6.280090];
    CLLocation * n2 = [[CLLocation alloc] initWithLatitude:53.346884 longitude:-6.282493];
    CLLocation * o1 = [[CLLocation alloc] initWithLatitude:53.339449 longitude:-6.280101];
    
    DBBusStop *s1 = [DBBusStop busStopWithNUmber:0 location:n1.coordinate address:@"ciao" isFavorite:NO];
    DBBusStop *s2 = [DBBusStop busStopWithNUmber:1 location:n2.coordinate address:@"ciao" isFavorite:YES];
    DBBusStop *s3 = [DBBusStop busStopWithNUmber:2 location:o1.coordinate address:@"ciao" isFavorite:YES];
    [c insertStopsFromArray:@[s1,s2,s3]];
}

-(void)test00getStopTest{
    
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    [self loadData:c];
    DBStopsManager * manager = [[DBStopsManager alloc] initWithDatabaseController: c];
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"get1666"];
    
    void (^handler1)(DBBusStop *) = ^(DBBusStop *stop) {
        if (stop) {
            XCTAssertEqual(1, stop.stopNumber);
            [e1 fulfill];
        }
    };
    
    [manager stopWithNumber:1 handler: handler1];
    
    
    
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"get1666"];
    
    void (^handler2)(DBBusStop *) = ^(DBBusStop *stop) {
        if (!stop) {
            [e2 fulfill];
        }
    };
    
    [manager stopWithNumber:166666 handler: handler2];
    
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
}

- (void) test001testSetFavorite{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    [self loadData:c];
    DBStopsManager * manager = [[DBStopsManager alloc] initWithDatabaseController: c];
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"favorites"];
    [manager setStop:0 asFavorite:YES handler:^(BOOL result) {
        XCTAssertTrue(result);
        [e1 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTestExpectation * r1 = [self expectationWithDescription:@"favorites"];
    [manager stopWithNumber:0 handler:^(DBBusStop *stop) {
        XCTAssertEqual(YES, stop.favorite);
        [r1 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"favorites"];
    [manager setStop:0 asFavorite:YES handler:^(BOOL result) {
        XCTAssertTrue(result);
        [e2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTestExpectation * r2 = [self expectationWithDescription:@"favorites"];
    [manager stopWithNumber:0 handler:^(DBBusStop *stop) {
        XCTAssertEqual(YES, stop.favorite);
        [r2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    
    XCTestExpectation * e3 = [self expectationWithDescription:@"favorites"];
    [manager setStop:1 asFavorite:NO handler:^(BOOL result) {
        XCTAssertTrue(result);
        [e3 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    XCTestExpectation * r3 = [self expectationWithDescription:@"favorites"];
    [manager stopWithNumber:1 handler:^(DBBusStop *stop) {
        XCTAssertEqual(NO, stop.favorite);
        [r3 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)test01testFetchAllFavorites{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    [self loadData:c];
    
    DBStopsManager * manager = [[DBStopsManager alloc] initWithDatabaseController: c];
    
    XCTestExpectation * e1 = [self expectationWithDescription:@"favorites"];
    
    
    [manager favorites:^(NSArray *stops) {
        for (DBBusStop * s in stops) {
            if (s.stopNumber != 1 && s.stopNumber != 2) {
                XCTFail(@"Not a favorite");
            }
        }
         [e1 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    [c setStopWithNumber:2 asFavorite:NO];
    
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"favorites2"];
    
    
    [manager favorites:^(NSArray *stops) {
        for (DBBusStop * s in stops) {
            if (s.stopNumber != 1) {
                XCTFail(@"Not a favorite");
            }
        }
        [e2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test02stopsNearLocation{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    [self loadData:c];
    DBStopsManager * manager = [[DBStopsManager alloc] initWithDatabaseController: c];
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"near"];
    CLLocation * n1 = [[CLLocation alloc] initWithLatitude:53.349881 longitude:-6.280090];
    [manager stopsNearLocation:n1 handler:^(NSArray *stops) {
        XCTAssertEqual(2, stops.count);
        for (DBBusStop * stop in stops) {
            if (stop.stopNumber != 0 && stop.stopNumber != 1) {
                XCTFail(@"Wrong stop");
            }
        }
        [e2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test03favoritesNearLocation{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    [self loadData:c];
    DBStopsManager * manager = [[DBStopsManager alloc] initWithDatabaseController: c];
    
    XCTestExpectation * e2 = [self expectationWithDescription:@"near"];
    CLLocation * n1 = [[CLLocation alloc] initWithLatitude:53.349881 longitude:-6.280090];
    [manager favoritesNearLocation:n1 handler:^(NSArray *stops) {
        if (stops.count != 1 || [stops[0] stopNumber] != 1) {
            XCTFail(@"Wrong stop");
        }
        [e2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end