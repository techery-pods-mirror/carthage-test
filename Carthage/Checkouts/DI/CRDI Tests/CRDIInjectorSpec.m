//
//  CRDIInjectorSpec.m
//  CRDI
//
//  Created by TheSooth on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDIInjector.h"
#import "CRDIContainer.h"

#import "CRDISampleClass.h"
#import "CRDISampleProtocol.h"
#import "CRDIInjectedClass.h"

SPEC_BEGIN(CRDIInjectorSpec)

describe(@"CRDIInjector Specs", ^{
    __block CRDISampleClass *_sampleObject;
    __block id _builderMock;
    __block id _containerMock;
    
    beforeEach(^{
        _sampleObject = [CRDISampleClass new];
        
        _builderMock = [KWMock mockForProtocol:@protocol(CRDIDependencyBuilder)];
        [_builderMock stub:@selector(build) andReturn:_sampleObject];
        
        _containerMock =[KWMock mockForClass:[CRDIContainer class]];
        [_containerMock stub:@selector(builderForProtocol:) andReturn:_builderMock];
    });
    
    it(@"Should return this same object for default injector", ^{
        CRDIInjector *injector = [[CRDIInjector alloc] initWithContainer:_containerMock];
        
        [CRDIInjector setDefaultInjector:injector];
        
        [[injector should] equal:[CRDIInjector defaultInjector]];
    });
    
    it(@"Should return object with injected property", ^{
        CRDIInjector *injector = [[CRDIInjector alloc] initWithContainer:_containerMock];
        
        CRDIInjectedClass *classWhichMustBeInjected = [CRDIInjectedClass new];
        
        [injector injectTo:classWhichMustBeInjected];
        
        [[classWhichMustBeInjected.ioc_injected shouldNot] beNil];
        
        [[classWhichMustBeInjected.ioc_injected should] equal:_sampleObject];
        
        [[theValue([classWhichMustBeInjected.ioc_injected conformsToProtocol:@protocol(CRDISampleProtocol)]) should] beTrue];
    });
    
    it(@"should throw an exception if nil instance for inject is received", ^{
        CRDIInjector *injector = [[CRDIInjector alloc] initWithContainer:_containerMock];
        
        [[theBlock(^{
            [injector injectTo:nil];
        }) should] raise];
        
    });
    
    context(@"Initialization", ^{
        it(@"should throw an exception if nil container is received", ^{
            [[theBlock(^{
                CRDIInjector *injector = [[CRDIInjector alloc] initWithContainer:nil];
            }) should] raise];
        });
        
        it(@"should throw an exception if defaul init is used", ^{
            [[theBlock(^{
                CRDIInjector *injector = [[CRDIInjector alloc] init];
            }) should] raise];
        });
        
    });
    
});

SPEC_END
