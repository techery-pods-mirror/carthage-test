//
//  DIPropertyModel.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "DIPropertyModel.h"

@implementation DIPropertyModel

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@; Protocol: %@", self.name, self.protocol];
}

@end
