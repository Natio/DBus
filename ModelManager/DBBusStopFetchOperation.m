//
//  DBBusStopFetchOperation.m
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBBusStopFetchOperation.h"
#import "DBBusStop.h"
#import "DBBusStopFetchOperation_Private.h"

#define API_ENDPOINT @"http://www.dublinbus.ie/Templates/Public/RoutePlannerService/RTPIMapHandler.ashx?ne=53.631314,-5.799202&sw=53.054946,-6.735786&zoom=10&czoom=16"

@interface DBBusStopFetchOperation ()
@property (nonatomic, strong) DBBusStopFetchOperationHandler handler;
@property (nonatomic, assign) BOOL hasInjectedData;
@end

@implementation DBBusStopFetchOperation

- (instancetype)initWithHandler:(DBBusStopFetchOperationHandler)handler{
    if (self = [super init]) {
        _handler = handler;
    }
    return self;
}

- (void)setData:(NSData *)data{
    if (data != _data) {
        _data = data;
    }
    self.hasInjectedData = YES;
}

- (NSData *)downloadData{
    return self.hasInjectedData ? self.data : [NSData dataWithContentsOfURL: [NSURL URLWithString:API_ENDPOINT]];
}

- (void)main{
    NSData * data = [self downloadData];
    NSMutableArray * storage = [NSMutableArray new];
    
    if (data) {
        NSDictionary * root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary * points = [root objectForKey:@"points"];
        if ([points isKindOfClass:[NSArray class]]) {
            for (NSDictionary * item in points) {
                
                if (![item isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                NSNumber * lat = item[@"lat"];
                NSNumber * lon = item[@"lng"];
                NSString * stopNumber = item[@"stopnumber"];
                NSString * address = item[@"address"];
                if (address && stopNumber && lat && lon) {
                    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
                    DBBusStop * stop = [DBBusStop busStopWithNUmber:[stopNumber intValue] location:coord address:address isFavorite:NO];
                    [storage addObject:stop];
                }
            }
        }
    }
    
    DBBusStopFetchOperationHandler handler = [self handler];
    self.handler = NULL;
    
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(storage);
        });
    }
}

@end
