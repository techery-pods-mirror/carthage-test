//
//  CRDISingletoneBuilder.h
//  CRDI
//
//  Created by Vladimir Shevchenko on 16.09.13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIDependencyBuilder.h"

@interface CRDISingletoneBuilder : NSObject <CRDIDependencyBuilder>

- (id)initWithBuilder:(id <CRDIDependencyBuilder>)aBuilder;

@end
