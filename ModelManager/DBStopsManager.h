//
//  DBStopsManager.h
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBBusStop;
@class CLLocation;
@class DBRealTimeStop;

@interface DBStopsManager : NSObject

+ (nonnull instancetype)sharedInstance;

- (void)stopWithNumber:(NSInteger)stopNumber handler:(nonnull void(^)( DBBusStop * __nullable  stop))handler;
- (void)favorites:(nonnull void(^)(NSArray * __nonnull stops))handler;
- (void)stopsNearLocation:(nonnull CLLocation *)center handler:(nonnull void(^)(NSArray * __nonnull stops))handler;
- (void)stopsNearLocation:(nonnull CLLocation *)center favorite:(BOOL)fav handler:(nonnull void(^)(NSArray * __nonnull stops))handler;
- (void)favoritesNearLocation:(nonnull CLLocation *)center handler:(nonnull void(^)(NSArray * __nonnull stops))handler;
- (void)setStop:(NSInteger)stopNumber asFavorite:(BOOL)favorite handler:(nonnull void(^)(BOOL))handler;
- (void)getRealTimeDataForStop:(NSInteger) stopNumber handler:(nonnull void(^)(DBRealTimeStop * __nonnull stop))handler;

@end