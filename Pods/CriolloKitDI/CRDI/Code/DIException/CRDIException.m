//
//  DIException.m
//  CRDI
//
//  Created by TheSooth on 9/17/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIException.h"

@implementation CRDIException

+ (CRDIException *)exceptionWithReason:(NSString *)aReason
{
    return (CRDIException *)[CRDIException exceptionWithName:@"CRDIException" reason:aReason userInfo:nil];
}

@end
