//
//  DBBusStopFetchOperation.h
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBOperation.h"

typedef void (^DBBusStopFetchOperationHandler)(NSArray * __nonnull results);

@interface DBBusStopFetchOperation : DBOperation

- (nonnull instancetype)initWithHandler:(DBBusStopFetchOperationHandler __nonnull)handler;

@end
