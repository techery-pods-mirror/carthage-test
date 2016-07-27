//
//  CRDIDefaultPropertyNameMatcher.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIDefaultPropertyNameMatcher.h"

static NSString * const kDefaultPrefix = @"ioc_";

@implementation CRDIDefaultPropertyNameMatcher

- (BOOL)shouldInject:(NSString *)propertyName
{
    return [propertyName hasPrefix:kDefaultPrefix] && propertyName.length > kDefaultPrefix.length;
}

@end
