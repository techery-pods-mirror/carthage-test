//
//  CRDIClassBuilder.h
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIDependencyBuilder.h"

@interface CRDIClassBuilder : NSObject <CRDIDependencyBuilder>

@property (nonatomic, unsafe_unretained, readonly) Class classForBuild;

- (id)initWithClass:(Class)aClass;

@end
