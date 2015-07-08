//
//  DBBusStopFetchOperation_Private.h
//  DBus
//
//  Created by Paolo Coronati on 06/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBBusStopFetchOperation.h"

@interface DBBusStopFetchOperation ()
- (NSData *)downloadData;
@property (nonatomic, strong) NSData * data;
@end
