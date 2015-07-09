//
//  DBOperation.m
//  DBus2
//
//  Created by Paolo Coronati on 08/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBOperation.h"
#import "DBOperation_Private.h"

@implementation DBOperation

- (instancetype)init{
    self = [super init];
    if (self) {
        _hasInjectedData = NO;
    }
    return self;
}

- (nullable NSData *)downloadData{
    return self.hasInjectedData ? self.data : nil;
}

- (void)setData:(NSData * __nullable)data{
    if (_data != data) {
        _data = data;
    }
    self.hasInjectedData = YES;
}

@end
