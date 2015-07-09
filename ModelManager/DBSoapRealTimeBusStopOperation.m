//
//  DBSoapRealTimeBusStopOperation.m
//  DBus2
//
//  Created by Paolo Coronati on 08/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBSoapRealTimeBusStopOperation.h"
#import "DBOperation_Private.h"
#import "GDataXMLNode.h"

@interface DBSoapRealTimeBusStopOperation ()

@property (nonatomic, strong, nonnull) DBSoapRealTimeBusStopOperationHandler handler;
@property (nonatomic, assign) NSInteger stopNumber;

@end

@implementation DBSoapRealTimeBusStopOperation

-(nonnull instancetype)initWithStopNumber:(NSInteger)stopNumber handler:(DBSoapRealTimeBusStopOperationHandler __nonnull)handler{
    if (self = [super init]) {
        _handler = handler;
        _stopNumber = stopNumber;
    }
    return self;
}

- (nullable NSData *)downloadData{
    if (self.hasInjectedData) {
        return self.data;
    }
    
    NSString * soapBody =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetRealTimeStopData xmlns=\"http://dublinbus.ie/\"><stopId>%ld</stopId><forceRefresh>false</forceRefresh></GetRealTimeStopData></soap:Body></soap:Envelope>", self.stopNumber];
    
    NSURL * url = [NSURL URLWithString:@"http://rtpi.dublinbus.ie/DublinBusRTPIService.asmx?op=GetRealTimeStopData"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding: NSUTF8StringEncoding]];
    [request setValue:@"http://dublinbus.ie/GetRealTimeStopData" forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];

    return [NSURLConnection sendSynchronousRequest: request returningResponse:nil error:nil];
}

- (void)main{
    NSData * data = [self downloadData];
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError * error = nil;
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithXMLString:string options:0 error:&error];
    if (error) {
        NSLog(@"%@",error);
        __weak DBSoapRealTimeBusStopOperation * weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.handler([DBRealTimeStop stopWithNumber:self.stopNumber routes:@[]]);
        });
        return;
    }
    
    DBRealTimeStop * resultStop = nil;
    
    GDataXMLElement * root = [doc rootElement];
    NSArray * body = [root elementsForName:@"soap:Body"];
    if ([body count] > 0) {
       GDataXMLElement * soapBody = [body objectAtIndex:0];
        NSArray * response = [soapBody elementsForName:@"GetRealTimeStopDataResponse"];
        if ([response count] > 0) {
            GDataXMLElement * responseElement = [response objectAtIndex:0];
            NSArray * result = [responseElement elementsForName:@"GetRealTimeStopDataResult"];
            if ([result count] > 0) {
                GDataXMLElement * resultElement = [result objectAtIndex:0];
                NSArray * dif = [resultElement elementsForName:@"diffgr:diffgram"];
                GDataXMLElement * difEl = [dif objectAtIndex:0];
                NSArray * doc = [difEl elementsForName:@"DocumentElement"];
                if ([doc count] > 0) {
                    GDataXMLElement * docEl = [doc objectAtIndex:0];
                    resultStop = [self stopFromXML_Array: [docEl children]];
                }
            }
        }
    }
    
    if (resultStop == nil) {
        resultStop = [DBRealTimeStop stopWithNumber:self.stopNumber routes:@[]];
    }
    
    __weak DBSoapRealTimeBusStopOperation * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.handler(resultStop);
    });
    
}

- (nonnull DBRealTimeStop *)stopFromXML_Array:(NSArray * __nonnull )array{
    NSMutableArray * routes = [NSMutableArray array];
    NSString * template = @"yyyy-MM-dd'T'HH:mm:sszzz";
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:template];
    for (GDataXMLElement * element in array) {
        GDataXMLElement * routeElement = [[element elementsForName:@"MonitoredVehicleJourney_PublishedLineName"] objectAtIndex:0];
        GDataXMLElement * arrivalTimeElement = [[element elementsForName:@"MonitoredCall_ExpectedArrivalTime"] objectAtIndex:0];
        NSDate * eta = [formatter dateFromString: arrivalTimeElement.stringValue];
        NSLog(@"%@ %@",routeElement.stringValue, arrivalTimeElement.stringValue);
        NSLog(@"%@",eta);
        NSLog(@"%@",[formatter stringFromDate:eta]);
    }
    return [DBRealTimeStop stopWithNumber:self.stopNumber routes:routes];
}

@end





















