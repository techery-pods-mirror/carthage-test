//
//  CRDIErrorHandlerProtocol.h
//  CRDI
//
//  Created by Max on 2/10/16.
//  Copyright © 2016 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRDIErrorHandlerProtocol <NSObject>

- (void)handleError:(NSError *)error;

@end
