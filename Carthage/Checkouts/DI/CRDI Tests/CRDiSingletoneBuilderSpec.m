//
//  CRDiSingletoneBuilderSpec.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDISingletoneBuilder.h"
#import "CRDISampleClass.h"
#import "CRDIClassBuilder.h"

SPEC_BEGIN(CRDiSingletoneBuilderSpec)

describe(@"CRDiSingletoneBuilderSpec", ^{
    
    __block CRDIClassBuilder *classBuilder = nil;
    __block CRDISingletoneBuilder *singletoneBuilder = nil;
    
    beforeEach(^{
        classBuilder = [[CRDIClassBuilder alloc] initWithClass:[CRDISampleClass class]];
        singletoneBuilder = [[CRDISingletoneBuilder alloc] initWithBuilder:classBuilder];
    });
    
    
    it(@"Should return instance with same class of instance builder", ^{
        id instance = [singletoneBuilder build];
        [[instance should] beKindOfClass:[CRDISampleClass class]];
    });
    
    it(@"Should raise due to init with nil object", ^{
        [[theBlock(^{
            [[CRDISingletoneBuilder alloc] initWithBuilder:nil];
        }) should] raise];
    });
    
    it(@"Should raise do to init with object what not implement CRDIDependencyBuilder protocol", ^{
        [[theBlock(^{
            [[CRDISingletoneBuilder alloc] initWithBuilder:@""];
        }) should] raise];
    });
    
    it(@"Should return same object builded from singletone builder", ^{
        CRDISampleClass *sampleObject = [singletoneBuilder build];
        CRDISampleClass *sameSampleObject = [singletoneBuilder build];
        
        [[sampleObject should] equal:sameSampleObject];
    });
    
});

SPEC_END