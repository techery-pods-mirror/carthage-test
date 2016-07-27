//
//  TEStoreStateStack.h
//  MasterApp
//
//  Created by Alexey Fayzullov on 9/10/15.
//  Copyright (c) 2015 Techery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEDomainMiddleware.h"
#import "TEStoreStateObserver.h"

@interface TEStatesTracer : TEStoreStateObserver  <TEDomainMiddleware>

- (NSArray *)statesTraceForStoreClass:(Class)storeClass;
- (NSArray *)statesTraceForStore:(TEBaseStore *)store;

@end
