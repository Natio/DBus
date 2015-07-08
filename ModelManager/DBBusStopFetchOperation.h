//
//  DBBusStopFetchOperation.h
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DBBusStopFetchOperationHandler)(NSArray * results);

@interface DBBusStopFetchOperation : NSOperation
- (instancetype)initWithHandler:(DBBusStopFetchOperationHandler)handler;
@end
