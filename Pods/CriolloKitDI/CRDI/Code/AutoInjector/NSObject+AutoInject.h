//
//  NSObject+AutoInject.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRDIInstanceInjector.h"

@interface NSObject (AutoInject)

+ (void)setInjector:(id <CRDIInstanceInjector>)injector;
+ (id <CRDIInstanceInjector>)injector;

- (id)initWithInject;

@end
