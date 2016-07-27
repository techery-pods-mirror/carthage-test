//
//  CRDIInjectedClassChild.h
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIInjectedClass.h"

@interface CRDIInjectedClassChild : CRDIInjectedClass

@property (nonatomic, strong) NSObject <CRDISampleProtocol> *ioc_child;

@end
