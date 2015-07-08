//
//  DatabaseController.m
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBDatabaseController.h"
#import "DBBusStop.h"
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>
#import "DBBusStop+Private.h"

#define R 6371
#define TO_RAD (3.1415926536 / 180.0)
double dist(double th1, double ph1, double th2, double ph2)
{
    double dx, dy, dz;
    ph1 -= ph2;
    ph1 *= TO_RAD, th1 *= TO_RAD, th2 *= TO_RAD;
    
    dz = sin(th1) - sin(th2);
    dx = cos(ph1) * cos(th1) - cos(th2);
    dy = sin(ph1) * cos(th1);
    return asin(sqrt(dx * dx + dy * dy + dz * dz) / 2) * 2 * R * 1000.0;
}

inline double distance(double lat1, double lon1, double lat2, double lon2){
    return dist(lat1, lon1, lat2, lon2);
}

@interface DBDatabaseController ()
@property (nonatomic, assign, readonly) sqlite3 * database;
@property (nonatomic, strong) NSCache * cachedObjects;
@end

@implementation DBDatabaseController{
    
}

- (void)dealloc{
    sqlite3_close(self.database);
}

- (instancetype)initWithDatabase:(sqlite3 *)db{
    NSAssert(db != NULL, @"database must not be null");
    if (self = [super init]) {
        _database = db;
        _cachedObjects = [[NSCache alloc] init];
    }
    [self createBusStopsTableIfNotExists];
    return self;
}


static void haversineDistance(sqlite3_context *context, int argc, sqlite3_value **argv){
    if(argc != 4){
        sqlite3_result_null(context);
        return;
    }
    
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    
    double dist = distance(lat1, lon1, lat2, lon2);
    
    sqlite3_result_double(context, dist);
}

+(nullable instancetype)controllerWithDatabaseAtPath:(nonnull NSString *) path;{
    
    sqlite3 * db;
    int result;
    int createFunction;
    result = sqlite3_open([path UTF8String], &db);
    createFunction = sqlite3_create_function(db, "haversine", 4, SQLITE_UTF8, NULL, &haversineDistance, NULL, NULL);

    if(result != SQLITE_OK && createFunction != SQLITE_OK){
        return nil;
    }
    
    return [[self alloc] initWithDatabase: db];
}

- (BOOL) createBusStopsTableIfNotExists{
    const char * createStm = "CREATE TABLE IF NOT EXISTS stops("
                             "stopNumber INT PRIMARY KEY NOT NULL,"
                             "address TEXT NOT NULL,"
                             "favorite INT NOT NULL,"
                             "latitude REAL NOT NULL,"
                             "longitude REAL NOT NULL);"
                             "CREATE INDEX IF NOT EXISTS stops_latitude_idx ON stops (latitude);"
                             "CREATE INDEX IF NOT EXISTS stops_longitude_idx ON stops (longitude);"
                             "CREATE INDEX IF NOT EXISTS stops_favorite_idx ON stops (favorite);";
    /*
    sqlite3_stmt * statement;
    
    if(sqlite3_prepare_v2(self.database, createStm, -1, &statement, NULL) != SQLITE_OK){
        return NO;
    }
    */
    
    
    
    int result = sqlite3_exec(self.database, createStm, NULL, NULL, NULL);
    return  result == SQLITE_OK;
}

- (BOOL)insertStopsFromArray:(nonnull NSArray * ) stops{
    BOOL result = YES;
    sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, NULL);
    const char * buffer = "INSERT INTO stops (stopNumber, address, favorite, latitude, longitude) VALUES (?1, ?2, ?3, ?4, ?5)";
    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(self.database, buffer, (int)strlen(buffer), &stmt, NULL) == SQLITE_OK){
        for(DBBusStop * stop in stops){
            sqlite3_bind_int(stmt, 1, (int)stop.stopNumber);
            sqlite3_bind_text(stmt, 2, [stop.address UTF8String], (int)[stop.address length], SQLITE_STATIC);
            sqlite3_bind_int(stmt, 3, stop.favorite);
            sqlite3_bind_double(stmt, 4, stop.coordinate.latitude);
            sqlite3_bind_double(stmt, 5, stop.coordinate.longitude);
            int step = sqlite3_step(stmt);
            if (step != SQLITE_DONE) {
                result = NO;
                NSLog(@"Error inserting stop (%ld): %s",(long)stop.stopNumber, sqlite3_errmsg(self.database));
            }
            sqlite3_reset(stmt);
        }
    }
    sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, NULL);
    if (stmt) {
        sqlite3_finalize(stmt);
    }
    return result;
}

- (NSInteger)numberOfStops:(BOOL)favorites{
    NSString * select = [NSString stringWithFormat:@"SELECT count(stopNumber) AS count FROM stops WHERE favorite = %d;", favorites];
    const char * selectCount = [select UTF8String];
    sqlite3_stmt * statement;
    NSInteger result = -1;
    if(sqlite3_prepare_v2(self.database, selectCount, -1, &statement, NULL) == SQLITE_OK){
        if (sqlite3_step(statement) == SQLITE_ROW) {
            result = sqlite3_column_int(statement, 0);
        }
    }
    return result;
}

- (NSInteger)totalNumberOfStops{
    NSString * select = @"SELECT count(stopNumber) AS count FROM stops WHERE 1";
    const char * selectCount = [select UTF8String];
    sqlite3_stmt * statement;
    NSInteger result = -1;
    if(sqlite3_prepare_v2(self.database, selectCount, -1, &statement, NULL) == SQLITE_OK){
        if (sqlite3_step(statement) == SQLITE_ROW) {
            result = sqlite3_column_int64(statement, 0);
        }
    }
    return result;
}

- (NSInteger)numberOfStops{
    return [self numberOfStops:NO];
}
- (NSInteger)numberOfFavorites{
    return [self numberOfStops:YES];
}

- (nonnull NSArray *)getStopsNearLocation:(nonnull CLLocation *)center radius:(double)radius limit:(NSInteger)limit type:(DBBusStopFetchType)type{
    CLLocationCoordinate2D coordinates = center.coordinate;
    
    NSMutableString * selectStm= [NSMutableString stringWithFormat:@"SELECT stopNumber, address,favorite, latitude, longitude, "];
    [selectStm appendFormat:@" haversine(latitude, longitude, %f, %f) as distance FROM stops ",coordinates.latitude, coordinates.longitude];
    [selectStm appendFormat:@" WHERE distance < %f ", radius];
    
    switch (type) {
        case DBBusStopFetchTypeNonFavoritesOnly:
            [selectStm appendFormat:@" AND favorite = %d ", NO];
            break;
        case DBBusStopFetchTypeFavoriteOnly:
            [selectStm appendFormat:@" AND favorite = %d ", YES];
            break;
        case DBBusStopFetchTypeAll:
            //fall to default
        default:
            break;
    }
    
    [selectStm appendFormat:@" ORDER BY distance LIMIT 0, %ld ", (long)limit];

    
    sqlite3_stmt * statement;
    NSMutableArray * result = [NSMutableArray new];
    
    if(sqlite3_prepare_v2(self.database, [selectStm UTF8String], -1, &statement, NULL) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger stopNumber = sqlite3_column_int(statement, 0);
            char * address = (char *) sqlite3_column_text(statement, 1);
            int fav = sqlite3_column_int(statement, 2);
            double lat = sqlite3_column_double(statement, 3);
            double lon = sqlite3_column_double(statement, 4);
            //double dist = sqlite3_column_double(statement, 5);
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
            NSString * addr = [[NSString alloc] initWithUTF8String:address];
            DBBusStop * stop = [DBBusStop busStopWithNUmber:stopNumber location:coord address:addr isFavorite:fav];
            [result addObject: stop];
        }
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"%s\n", sqlite3_errmsg(self.database));
    }
    return result;
}

- (nonnull NSArray *)getFavorites{
    NSString * selectStm = @"SELECT stopNumber, address,favorite, latitude, longitude FROM stops WHERE favorite = 1";
    
    sqlite3_stmt * statement;
    NSMutableArray * result = [NSMutableArray new];
    
    if(sqlite3_prepare_v2(self.database, [selectStm UTF8String], -1, &statement, NULL) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger stopNumber = sqlite3_column_int(statement, 0);
            char * address = (char *) sqlite3_column_text(statement, 1);
            int fav = sqlite3_column_int(statement, 2);
            double lat = sqlite3_column_double(statement, 3);
            double lon = sqlite3_column_double(statement, 4);
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
            NSString * addr = [[NSString alloc] initWithUTF8String:address];
            DBBusStop * stop = [DBBusStop busStopWithNUmber:stopNumber location:coord address:addr isFavorite:fav];
            [result addObject: stop];
        }
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"%s\n", sqlite3_errmsg(self.database));
    }
    return result;
}

- (nullable DBBusStop *)getBusStopWithNumber:(NSInteger) number{
    NSString * key = [NSString stringWithFormat:@"%ld", (long)number];
    DBBusStop * stop = [self.cachedObjects objectForKey:key];
    if (nil != stop) {
        return stop;
    }
    
    NSString * selectStm = [NSString stringWithFormat:@"SELECT stopNumber, address,favorite, latitude, longitude FROM stops WHERE stopNumber = %ld", (long)number ];
    
    sqlite3_stmt * statement;
    DBBusStop * result = nil;
    
    if(sqlite3_prepare_v2(self.database, [selectStm UTF8String], -1, &statement, NULL) == SQLITE_OK){
        if (sqlite3_step(statement) == SQLITE_ROW) {
            NSInteger stopNumber = sqlite3_column_int(statement, 0);
            char * address = (char *) sqlite3_column_text(statement, 1);
            NSInteger fav = sqlite3_column_int(statement, 2);
            double lat = sqlite3_column_double(statement, 3);
            double lon = sqlite3_column_double(statement, 4);
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
            NSString * addr = [[NSString alloc] initWithUTF8String:address];
            result = [DBBusStop busStopWithNUmber:stopNumber location:coord address:addr isFavorite:fav];
        }
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"%s\n", sqlite3_errmsg(self.database));
    }
    if (result) {
        [self.cachedObjects setObject: result forKey:key];
    }
    return result;
}

- (BOOL)setStopWithNumber:(NSInteger)stopNumber asFavorite:(BOOL)favorite{
    
    DBBusStop * stop = [self.cachedObjects objectForKey:[NSString stringWithFormat:@"%ld", (long)stopNumber]];
    if (nil != stop) {
        [stop setFavorite:favorite];
    }
    
    NSString * update = [NSString stringWithFormat:@"UPDATE stops SET favorite = %d WHERE stopNumber = %ld", favorite, (long)stopNumber];
    
    sqlite3_stmt * statement;
    BOOL result = NO;
    
    if (sqlite3_prepare_v2(self.database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Bus stop updated");
            
            result = sqlite3_changes(self.database) == 1;
        }
        else{
            NSLog(@"Error updating the bu stop");
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error preparing the update statement");
    }
    
    return result;
}

@end









