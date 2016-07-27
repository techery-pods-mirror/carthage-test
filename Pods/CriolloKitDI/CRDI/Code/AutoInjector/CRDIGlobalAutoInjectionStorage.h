//
//  CRDIGlobalAutoInjectorStorage.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CRDIInstanceInjector.h"

@interface CRDIGlobalAutoInjectionStorage : NSObject

+ (CRDIGlobalAutoInjectionStorage *)storage;
- (NSString*)put:(id <CRDIInstanceInjector>)injector;
- (id <CRDIInstanceInjector>)get:(NSString*)key;

@end
