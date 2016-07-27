//
//  DIClassTemplate.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIPropertyModel.h"

@interface DIClassTemplate : NSObject

@property (nonatomic, unsafe_unretained) Class templateClass;
@property (nonatomic, strong) NSArray *properties;

@end
