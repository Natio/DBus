//
//  DBRealTimeStop.h
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBRealTimeStopTime : NSObject

@property (nonatomic, strong, readonly, nonnull) NSDate * eta;
@property (nonatomic, strong, readonly, nonnull) NSString * route;
+ (nonnull instancetype)timeWithRoute:(NSString * __nonnull) route eta:(NSDate * __nonnull)eta;

@end

@interface DBRealTimeStop : NSObject

@property (nonatomic, readonly) NSInteger stopNumber;
@property (nonnull, readonly, strong, nonatomic) NSArray * buses;

+(nonnull instancetype)stopWithNumber:(NSInteger)stopNumber routes:(NSArray * __nonnull)route;

@end