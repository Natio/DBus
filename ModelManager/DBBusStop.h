//
//  DBBusStop.h
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DBBusStop : NSObject
@property (nonatomic, readonly, strong, nonnull) NSString * address;
@property (nonatomic, readonly, assign, getter=isFavorite) BOOL favorite;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, assign) NSInteger stopNumber;


+ (nonnull instancetype)busStopWithNUmber:(NSInteger)number
                                 location:(CLLocationCoordinate2D)coordinates
                                  address:(nonnull NSString *)address
                               isFavorite:(BOOL)fav;

@end
