//
//  DBStopsManager.m
//  DBus
//
//  Created by Paolo Coronati on 05/07/15.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

#import "DBStopsManager.h"
#import "DBDatabaseController.h"
#import "DBBusStopFetchOperation.h"
#import "DBBusStopRealTimeOperation.h"
#import "DBRealTimeStop.h"
#import "DBSoapRealTimeBusStopOperation.h"

#define EXECUTE_ON_MAIN(h,...) \
    do{\
        if((h)!= nil){\
            dispatch_async(dispatch_get_main_queue(), ^{\
                h(__VA_ARGS__);\
            });\
        }    \
    } while(0)

@interface DBStopsManager ()

@property (nonatomic, strong) DBDatabaseController * controller;
@property (nonatomic, assign) BOOL hasLoadedStops;
@property (nonatomic, strong) NSOperationQueue * networkQueue;
@property (nonatomic, strong) NSOperationQueue * databaseQueue;
-(void)instanciateDatabase;
@end

@implementation DBStopsManager

static DBStopsManager * sharedInstance = nil;

#pragma mark - Instanciation

+ (nonnull instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance instanciateDatabase];
    });
    return sharedInstance;
}

- (instancetype)initWithDatabaseController:(DBDatabaseController *)controller{
    if (self = [super init]){
        _controller = controller;
        _hasLoadedStops = YES;
        _networkQueue = [[NSOperationQueue alloc] init];
        _databaseQueue = [[NSOperationQueue alloc] init];
        [_databaseQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        _hasLoadedStops = NO;
        _networkQueue = [[NSOperationQueue alloc] init];
        _databaseQueue = [[NSOperationQueue alloc] init];
        [_databaseQueue setMaxConcurrentOperationCount:1];
        
    }
    return self;
}

-(void)instanciateDatabase{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self stopsFilePath]]){
        [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
            self.controller = [DBDatabaseController controllerWithDatabaseAtPath:[self stopsFilePath]];
        }]];
        [self.databaseQueue waitUntilAllOperationsAreFinished];
        self.hasLoadedStops = YES;
    }
    else{
        DBBusStopFetchOperation * fetch = [[DBBusStopFetchOperation alloc] initWithHandler:^(NSArray *results) {
            [self insertEntriesInDatabase: results];
        }];
        [self.networkQueue setMaxConcurrentOperationCount:1];
        [self.networkQueue addOperation: fetch];
    }
    
    
}

- (void)insertEntriesInDatabase:(NSArray *)stops{
    [self.networkQueue setSuspended:YES];
    [self.databaseQueue waitUntilAllOperationsAreFinished];
    
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        
        self.controller = [DBDatabaseController controllerWithDatabaseAtPath:[self stopsFilePath]];
        [self.controller insertStopsFromArray:stops];
        
        [self.networkQueue setSuspended:NO];
    }]];
}



- (NSString *)appGroupPath{
    return [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.natium.dbus"] path];
}

- (NSString *)stopsFilePath{
    NSString * path = [self appGroupPath];
    return [path stringByAppendingPathComponent:@"stops_db.sqlite"];
}

#pragma mark - Operations

- (void)stopWithNumber:(NSInteger)stopNumber handler:(nonnull void(^)( DBBusStop * __nullable  stop))handler{
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        
        DBBusStop * s = [self.controller getBusStopWithNumber:stopNumber];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(s);
        });
        
    }]];
}

- (void)favorites:(nonnull void(^)(NSArray * __nonnull stops))handler{
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSArray * favs = [self.controller getFavorites];
        EXECUTE_ON_MAIN(handler, favs);
    }]];
}
- (void)stopsNearLocation:(nonnull CLLocation *)center handler:(nonnull void(^)(NSArray * __nonnull stops))handler{
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSArray * stops = [self.controller getStopsNearLocation:center radius:1000.0 limit:15 type:DBBusStopFetchTypeAll];
        EXECUTE_ON_MAIN(handler, stops);
    }]];
}
- (void)favoritesNearLocation:(nonnull CLLocation *)center handler:(nonnull void(^)(NSArray * __nonnull stops))handler{
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSArray * stops = [self.controller getStopsNearLocation:center radius:1000.0 limit:15 type:DBBusStopFetchTypeFavoriteOnly];
        EXECUTE_ON_MAIN(handler, stops);
    }]];
}

- (void)stopsNearLocation:(nonnull CLLocation *)center favorite:(BOOL)fav handler:(nonnull void(^)(NSArray * __nonnull stops))handler{
    if (fav) {
        [self favoritesNearLocation:center handler: handler];
    }
    else{
        [self stopsNearLocation:center handler: handler];
    }
}

- (void)setStop:(NSInteger)stopNumber asFavorite:(BOOL)favorite handler:(nonnull void(^)(BOOL))handler;{
    [self.databaseQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        BOOL result = [self.controller setStopWithNumber:stopNumber asFavorite:favorite];
        EXECUTE_ON_MAIN(handler, result);
    }]];

}

- (void)getRealTimeDataForStop:(NSInteger) stopNumber handler:(nonnull void(^)(DBRealTimeStop * __nonnull stop))handler{
    [self.networkQueue addOperation:[[DBSoapRealTimeBusStopOperation alloc] initWithStopNumber:stopNumber handler:handler]];
}

@end
