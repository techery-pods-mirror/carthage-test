//
//  CRDIBlockBuilder.h
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIDependencyBuilder.h"
#import "CRDITypedefs.h"

@interface CRDIBlockBuilder : NSObject <CRDIDependencyBuilder>

- (id)initWithBlock:(CRDIContainerBindBlock)aBindBlock;

@end
