//
//  DBBusStop.m
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBBusStop.h"
#import <CoreLocation/CoreLocation.h>
#import "DBBusStop+Private.h"

@implementation DBBusStop

+ (nonnull instancetype)busStopWithNUmber:(NSInteger)number
                                 location:(CLLocationCoordinate2D)location
                                  address:(nonnull NSString *)address
                               isFavorite:(BOOL)fav{
    DBBusStop * stop = [[self alloc] init];
    stop->_address = [address copy];
    stop->_favorite = fav;
    stop->_coordinate = location;
    stop->_stopNumber = number;
    return stop;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<BusStop: %ld favorite: %d>", (long)self.stopNumber, self.favorite];
}

- (BOOL)isEqual:(id)object{
    if (!object || [object class] != [self class]) {
        return NO;
    }
    DBBusStop * other = object;
    return [self.address isEqual: other.address] && self.favorite == other.favorite && self.stopNumber == other.stopNumber;
}

- (NSUInteger)hash{
    return self.stopNumber;
}

- (void)setFavorite:(BOOL)favorite{
    self->_favorite = favorite;
}

@end
