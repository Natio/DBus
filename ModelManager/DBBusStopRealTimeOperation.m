//
//  DBBusStopRealTimeOperation.m
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBBusStopRealTimeOperation.h"
#import "DBBusStopRealTimeOperation_Private.h"
#import "ObjectiveGumbo.h"
#import "DBRealTimeStop.h"

#define BASE_URL @"http://www.dublinbus.ie/en/RTPI/Sources-of-Real-Time-Information/?searchtype=view&searchquery="

@interface DBBusStopRealTimeOperation ()

@property (nonatomic, copy) DBBusStopRealTimeOperationHandler __nonnull handler;
@property (nonatomic, assign) NSInteger stopNumber;
@property (nonatomic, assign) BOOL hasInjectedData;
@end

@implementation DBBusStopRealTimeOperation

- (nonnull instancetype)initWithStopNumber:(NSInteger)number handler:(DBBusStopRealTimeOperationHandler __nonnull)handler{
    if (self = [super init]) {
        _handler = [handler copy];
        _stopNumber = number;
        _hasInjectedData = NO;
    }
    return self;
}

- (void)setData:(NSData *)data{
    if (data != _data) {
        _data = data;
    }
    _hasInjectedData = YES;
}

- (NSData * )downloadData{
    NSURL * url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%ld",BASE_URL, (long)self.stopNumber]];
    return self.hasInjectedData ? self.data : [NSData dataWithContentsOfURL: url];
}

- (nullable NSDate *)dateFromTimeRepresentation:(nonnull NSString *)timeString{
    if ([timeString isEqual:@"Due"]) {
        return [NSDate date];
    }
    
    NSDate * toReturn = nil;
    
    NSArray * components = [timeString componentsSeparatedByString:@":"];
    if ([components count] == 2) {
        NSString * min = components[0];
        NSString * h = components[0];
        if (min && h){
            int minutes = [min intValue];
            int hour = [h intValue];
            NSDate * now = [NSDate date];
            NSCalendar * calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
            toReturn = [calendar dateBySettingHour:hour minute: minutes second: 0 ofDate: now options: 0];
        }
    }
    
    return toReturn;
}

- (void)main{
    NSData * data = [self downloadData];
    if (nil == data) {
        dispatch_async(dispatch_get_main_queue(),^{
            self.handler([DBRealTimeStop stopWithNumber:self.stopNumber routes:@[]]);
        });
        return;
    }
    
    NSMutableArray * buses = [NSMutableArray array];
    
    NSCharacterSet * charsToTrim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    OGDocument * document = [ObjectiveGumbo parseDocumentWithData: data encoding:NSUTF8StringEncoding];
    NSArray * tableContainersArray = [document elementsWithID:@"rtpi-results"];
    
    if ([tableContainersArray count] > 0) {
        OGNode * tableContainer = [tableContainersArray firstObject];
        NSArray * tableRows = [tableContainer elementsWithTag: GUMBO_TAG_TR];
        for (OGElement * row in tableRows) {
            if (![row.attributes[@"class"]isEqual:@"yellow"]) {
                NSArray * children = [row elementsWithTag:GUMBO_TAG_TD];
                if ([children count] < 4) {
                    NSLog(@"Number of column is less than 4");
                    continue;
                }
                NSString * time = [[children[2] text] stringByTrimmingCharactersInSet: charsToTrim];
                NSString * route = [[children[0] text] stringByTrimmingCharactersInSet: charsToTrim];
                if (time  && route) {
                    NSDate * eta = [self dateFromTimeRepresentation: time];
                    if (eta) {
                        DBRealTimeStopTime * r = [DBRealTimeStopTime timeWithRoute:route eta: eta];
                        [buses addObject: r];
                    }
                }
                else{
                    NSLog(@"Failed to parse time line: %@ time: %@", time, route);
                }
                
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.handler([DBRealTimeStop stopWithNumber:self.stopNumber routes:buses]);
    });
    
}

@end