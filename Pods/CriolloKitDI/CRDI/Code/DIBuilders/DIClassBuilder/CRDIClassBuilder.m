//
//  CRDIClassBuilder.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIClassBuilder.h"

@interface CRDIClassBuilder ()

@property (nonatomic, unsafe_unretained) Class classForBuild;

@end

@implementation CRDIClassBuilder

- (id)initWithClass:(Class)aClass
{
    NSParameterAssert(aClass);
    
    self = [super init];
    
    if (self) {
        self.classForBuild = aClass;   
    }
    
    return self;
}

- (id)build
{
    return [self.classForBuild new];
}

@end
