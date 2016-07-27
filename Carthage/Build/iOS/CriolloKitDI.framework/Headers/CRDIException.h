//
//  DIException.h
//  CRDI
//
//  Created by TheSooth on 9/17/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRDIException : NSException

+ (CRDIException *)exceptionWithReason:(NSString *)aReason;

@end
