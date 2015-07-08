//
//  DBBusStopRealTimeOperation.h
//  DBus
//
//  Created by Paolo Coronati on 07/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBRealTimeStop;

typedef void(^DBBusStopRealTimeOperationHandler) (DBRealTimeStop * __nonnull);

@interface DBBusStopRealTimeOperation : NSOperation

- (nonnull instancetype)initWithStopNumber:(NSInteger)number handler:(DBBusStopRealTimeOperationHandler __nonnull)handler;

@end
