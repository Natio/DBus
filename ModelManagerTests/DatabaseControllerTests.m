//
//  DatabaseControllerTests.m
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBDatabaseController.h"
#import <XCTest/XCTest.h>
#import <sqlite3.h>
#import "DBBusStop.h"
#import <CoreLocation/CoreLocation.h>
#import "DBStopsManager.h"

@interface DatabaseControllerTests : XCTestCase

@end

@implementation DatabaseControllerTests{
    NSString * _dbPath;
    CLLocation *_center;
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

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)test00instanciateDatabase{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];
    XCTAssertNotNil(c);
}

- (void)test02insertRows{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    CLLocation * loc1 = [[CLLocation alloc] initWithLatitude:0.01 longitude:0.02];
    
    DBBusStop * stop1 = [DBBusStop busStopWithNUmber:0 location:loc1.coordinate address:@"uno" isFavorite:YES];
    
    [c insertStopsFromArray:@[stop1]];
    
    XCTAssertEqual(0, [c numberOfStops:NO]);
    XCTAssertEqual(1, [c totalNumberOfStops]);
    
    DBBusStop * stop2 = [DBBusStop busStopWithNUmber:2 location:loc1.coordinate address:@"due" isFavorite:NO];
    
    [c insertStopsFromArray:@[stop1, stop2]];
    
    XCTAssertEqual(1, [c numberOfStops]);
    XCTAssertEqual(2, [c totalNumberOfStops]);
}

- (void)test03testInsertFavorite{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    
    XCTAssertEqual(2, [c numberOfFavorites]);
}

- (void)test04haversineDistance{
    
    CLLocation * n1 = [[CLLocation alloc] initWithLatitude:53.349881 longitude:-6.280090];
    CLLocation * n2 = [[CLLocation alloc] initWithLatitude:53.346884 longitude:-6.282493];
    CLLocationCoordinate2D c1 = n1.coordinate;
    CLLocationCoordinate2D c2 = n2.coordinate;
    
    double dist1 = [n1 distanceFromLocation:n2];
    double dist2 = distance(c1.latitude, c1.longitude, c2.latitude, c2.longitude);
    
    double diff = fabs(dist1 - dist2);
    double epsilon = 1;
    XCTAssertTrue(diff < epsilon);
    
}

- (void)test05fetchNearby{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    NSArray * result = [c getStopsNearLocation:_center radius:1000.0 limit:10 type: DBBusStopFetchTypeAll];
    for (DBBusStop * s in result) {
        if (s.stopNumber != 0 && s.stopNumber != 1) {
            XCTFail(@"Wrong stop");
        }
    }
    XCTAssertEqual(2, [result count]);
}

- (void)test05fetchNearbyFavorites{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    NSArray * result = [c getStopsNearLocation:_center radius:1000.0 limit:10 type:DBBusStopFetchTypeFavoriteOnly];
    XCTAssertEqual(1, [result count]);
    
}

- (void)test06getFavorites{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    NSArray * result = [c getFavorites];
    XCTAssertEqual(2, [result count]);
    
    for (DBBusStop * stop in result ) {
        XCTAssertEqual(stop.favorite, YES);
    }
}

- (void)test07getBusStopWithNumber{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    
    DBBusStop * s1 = [c getBusStopWithNumber:0];
    XCTAssertEqual(s1.stopNumber, 0);
    XCTAssertEqual(s1.favorite, NO);
    
    DBBusStop * s2 = [c getBusStopWithNumber:1];
    
    XCTAssertEqual(s2.stopNumber, 1);
    XCTAssertEqual(s2.favorite, YES);
}

- (void)test08setFavorite{
    DBDatabaseController * c = [DBDatabaseController controllerWithDatabaseAtPath:_dbPath];

    [self loadData:c];
    
    DBBusStop * s1 = [c getBusStopWithNumber:0];
    XCTAssertEqual(s1.favorite, NO);
    [c setStopWithNumber:s1.stopNumber asFavorite:YES];
    
    s1 = [c getBusStopWithNumber:0];
    XCTAssertEqual(s1.favorite, YES);
 
    DBBusStop * s2 = [c getBusStopWithNumber:1];
    XCTAssertEqual(s2.favorite, YES);
    [c setStopWithNumber:s2.stopNumber asFavorite:NO];
    
    s2 = [c getBusStopWithNumber:1];
    XCTAssertEqual(s2.favorite, NO);
}


@end










