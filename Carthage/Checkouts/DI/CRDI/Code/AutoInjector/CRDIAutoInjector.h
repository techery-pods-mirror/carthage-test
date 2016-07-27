//
//  CRDIAutoInjector.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+AutoInject.h"


@interface CRDIAutoInjector : NSObject

- (id)initWithInjector:(id <CRDIInstanceInjector>)anInjector;

- (void)attachToClass:(Class)classToAttach;

@end
