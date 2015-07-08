//
//  DBBusStopRealTimeOperation_Private.h
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBBusStopRealTimeOperation.h"

@interface DBBusStopRealTimeOperation ()

- (nullable NSDate *)dateFromTimeRepresentation:(nonnull NSString *)timeString;
- (nullable NSData *)downloadData;
@property (nonatomic, strong, nullable) NSData * data;

@end
