//
//  CRDIPropertyNameMatcher.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRDIPropertyNameMatcher <NSObject>

- (BOOL)shouldInject:(NSString *)propertyName;

@end
