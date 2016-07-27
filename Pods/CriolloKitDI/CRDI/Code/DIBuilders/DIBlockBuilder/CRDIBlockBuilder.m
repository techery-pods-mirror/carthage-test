//
//  CRDIBlockBuilder.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIBlockBuilder.h"

@interface CRDIBlockBuilder ()

@property (nonatomic, copy) CRDIContainerBindBlock bindBlock;

@end

@implementation CRDIBlockBuilder

- (id)initWithBlock:(CRDIContainerBindBlock)aBindBlock
{
    NSParameterAssert(aBindBlock);
    
    self = [super init];
    
    if (self) {
        self.bindBlock = aBindBlock;
    }
    
    return self;
}

- (id)build
{
    return self.bindBlock();
}

@end
