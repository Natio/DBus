//
//  DBOperation_Private.h
//  DBus2
//
//  Created by Paolo Coronati on 08/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBOperation.h"

@interface DBOperation ()

@property (nonatomic, strong, nullable) NSData * data;
@property (nonatomic, assign) BOOL hasInjectedData;

- (nullable NSData *)downloadData;

@end
