//
//  DatabaseController.h
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DBBusStopFetchTypeFavoriteOnly = 0,
    DBBusStopFetchTypeAll = 1,
    DBBusStopFetchTypeNonFavoritesOnly = 2
} DBBusStopFetchType;

double distance(double lat1, double lon1, double lat2, double lon2);

@class CLLocation;
@class DBBusStop;
@interface DBDatabaseController : NSObject

+(nullable instancetype)controllerWithDatabaseAtPath:(nonnull NSString *) path;
- (BOOL)insertStopsFromArray:(nonnull NSArray * ) stops;
- (NSInteger)numberOfStops;
- (NSInteger)numberOfFavorites;
- (NSInteger)numberOfStops:(BOOL)favorites;
- (NSInteger)totalNumberOfStops;
- (nonnull NSArray *)getStopsNearLocation:(nonnull CLLocation *)center radius:(double)radius limit:(NSInteger)limit type:(DBBusStopFetchType)type;
- (nonnull NSArray *)getFavorites;
- (nullable DBBusStop *)getBusStopWithNumber:(NSInteger) number;
- (BOOL)setStopWithNumber:(NSInteger)stopNumber asFavorite:(BOOL)favorite;

@end
