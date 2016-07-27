//
//  CRDIClassInspector.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIClassTemplate.h"
#import "CRDIPropertyNameMatcher.h"

@interface CRDIClassInspector : NSObject

- (id)initWithPropertyMatcher:(id<CRDIPropertyNameMatcher>)matcher;

- (DIClassTemplate*)inspect:(Class)instanceClass;

@end
