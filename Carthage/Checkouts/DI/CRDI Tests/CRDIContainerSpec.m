//
//  CRDIContainerSpec.m
//  CRDI Tests
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDIContainer.h"

#import "CRDIClassBuilder.h"
#import "CRDIBlockBuilder.h"
#import "CRDISingletoneBuilder.h"

#import "CRDISampleClass.h"
#import "CRDIInjectedClass.h"
#import "CRDISampleProtocol.h"

SPEC_BEGIN(CRDIContainerSpec)

describe(@"CRDIContainerSpecs", ^{
    context(@"Default container specs", ^{
        __block CRDIContainer *defaultContainer = nil;
        
        beforeEach(^{
            defaultContainer = [CRDIContainer new];
            [CRDIContainer setDefaultContainer:defaultContainer];
        });
        
        it(@"defaultContainer should not be nil", ^{
            [[[CRDIContainer defaultContainer] shouldNot] beNil];
        });
        
        it(@"container should be euqal to defaultContainer", ^{
            CRDIContainer *container = [CRDIContainer defaultContainer];
            
            [[container should] equal:defaultContainer];
        });
        
    });
    
    context(@"Container specs", ^{
        __block CRDIContainer *container = nil;
        Protocol *sampleProtocol = @protocol(CRDISampleProtocol);
        
        beforeEach(^{
            container = [CRDIContainer new];
        });
        
        it (@"Should return class builder", ^{
            
            [container bindClass:[CRDISampleClass class] toProtocol:sampleProtocol];
            
            NSObject *builder = [container builderForProtocol:sampleProtocol];
            
            [[builder shouldNot] beNil];
            
            [[builder should] beKindOfClass:[CRDIClassBuilder class]];
            
            [[theValue([builder conformsToProtocol:@protocol(CRDIDependencyBuilder)]) should] beTrue];
        });
        
        it(@"Should return block builder", ^{
            [container bindBlock:^id{
                return @"";
            } toProtocol:sampleProtocol];
            
            NSObject *builder = [container builderForProtocol:sampleProtocol];
            
            [[builder shouldNot] beNil];
            
            [[builder should] beKindOfClass:[CRDIBlockBuilder class]];
            
            [[theValue([builder conformsToProtocol:@protocol(CRDIDependencyBuilder)]) should] beTrue];
        });
        
        it(@"Should return eager singletone builder whis is binded to class builder", ^{
            [container bindEagerSingletoneClass:[CRDISampleClass class] toProtocol:sampleProtocol];
            
            NSObject *builder = [container builderForProtocol:sampleProtocol];
            
            [[builder shouldNot] beNil];
            
            [[builder should] beKindOfClass:[CRDISingletoneBuilder class]];
            
            [[theValue([builder conformsToProtocol:@protocol(CRDIDependencyBuilder)]) should] beTrue];
        });

        it(@"Should return eager singletone builder whis is binded to block builder", ^{
            [container bindEagerSingletoneBlock:^id{
                return @"";
            } toProtocol:sampleProtocol];
            
            NSObject *builder = [container builderForProtocol:sampleProtocol];
            
            [[builder shouldNot] beNil];
            
            [[builder should] beKindOfClass:[CRDISingletoneBuilder class]];
            
            [[theValue([builder conformsToProtocol:@protocol(CRDIDependencyBuilder)]) should] beTrue];
        });
        
        it(@"Should return array of builders for protocol", ^{
            [container bindClass:[CRDISampleClass class] toProtocol:sampleProtocol];
            [container bindClass:[CRDIInjectedClass class] toProtocol:sampleProtocol];
            
            NSArray *buildersArray = [container buidersForProtocol:sampleProtocol];
            
            [[buildersArray should] haveCountOf:2];
        });
        
        it(@"Should raise exception due to already added block for same protocol", ^{
            [container bindClass:[CRDISampleClass class] toProtocol:sampleProtocol];
            
            [[theBlock(^{
                [container bindBlock:^id{
                    return nil;
                } toProtocol:sampleProtocol];
            }) should] raise];
        });
        
    });

});

SPEC_END
