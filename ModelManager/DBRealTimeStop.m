//
//  DBRealTimeStop.m
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBRealTimeStop.h"


@implementation DBRealTimeStopTime

+ (nonnull instancetype)timeWithRoute:(NSString * __nonnull) route eta:(NSDate * __nonnull)eta{
    DBRealTimeStopTime * this = [[self alloc] init];
    this->_eta = eta;
    this->_route = route;
    return this;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ %@\n", self.route, self.eta];
}

@end


@implementation DBRealTimeStop

+ (nonnull instancetype)stopWithNumber:(NSInteger)stopNumber routes:(NSArray * __nonnull)route{
    DBRealTimeStop * this = [[self alloc] init];
    this->_stopNumber = stopNumber;
    
    this->_buses = [route sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(DBRealTimeStopTime*)a eta];
        NSDate *second = [(DBRealTimeStopTime*)b eta];
        return [first compare:second];
    }];
    
    return this;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"DBRealTimeStop %ld %@", (long)self.stopNumber, self.buses];
}

@end