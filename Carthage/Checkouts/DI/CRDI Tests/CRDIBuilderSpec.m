//
//  CRDIBuilderSpec.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDIClassBuilder.h"
#import "CRDIBlockBuilder.h"
#import "CRDIContainer.h"

#import "CRDISampleClass.h"

SPEC_BEGIN(CRDIClassBuilderSpec)

describe(@"CRDIClassBuilderSpecs", ^{
    context(@"Class builder", ^{
        __block CRDIClassBuilder *classBuilder = nil;
        
        beforeAll(^{
            classBuilder = [[CRDIClassBuilder alloc] initWithClass:[CRDISampleClass class]];
        });
        
        it(@"class builder should not be nil", ^{
            [[classBuilder shouldNot] beNil];
            [[classBuilder should] beKindOfClass:[CRDIClassBuilder class]];
        });
        
        it(@"builded object should not be nil", ^{
            [[[classBuilder build] shouldNot] beNil];
        });
        
        it(@"buider should build object of class CRSampleClass", ^{
            CRDISampleClass *sampleClass = [classBuilder build];
            
            [[sampleClass should] beKindOfClass:[CRDISampleClass class]];
        });
    });
    
    context(@"Block builder", ^{
        __block CRDIBlockBuilder *blockBuilder = nil;
        
        NSNumber *testingObject = @(100500);
        
        beforeAll(^{
            blockBuilder = [[CRDIBlockBuilder alloc] initWithBlock:^id{
                return testingObject;
            }];
        });
        
        it(@"should init not nil block builder", ^{
            [[blockBuilder shouldNot] beNil];
        });
        
        it(@"should build not nil object", ^{
            id buildedObject = [blockBuilder build];
            
            [[buildedObject shouldNot] beNil];
        });
        
        it(@"should return builded object of block", ^{
            id buildedObject = [blockBuilder build];
            
            [[buildedObject should] equal:testingObject];
        });
    });
});

SPEC_END
