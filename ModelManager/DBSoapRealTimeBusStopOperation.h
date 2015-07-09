//
//  DBSoapRealTimeBusStopOperation.h
//  DBus2
//
//  Created by Paolo Coronati on 08/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBOperation.h"
#import "DBRealTimeStop.h"

typedef void(^DBSoapRealTimeBusStopOperationHandler) (DBRealTimeStop * __nonnull stop);

@interface DBSoapRealTimeBusStopOperation : DBOperation

-(nonnull instancetype)initWithStopNumber:(NSInteger)stopNumber handler:(DBSoapRealTimeBusStopOperationHandler __nonnull)handler;

@end
