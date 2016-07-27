//
//  CRDIPropertyNameMatcher.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDIDefaultPropertyNameMatcher.h"

SPEC_BEGIN(CRDIPropertyNameMatcherSpec)

describe(@"Default matcher", ^{
    __block id<CRDIPropertyNameMatcher> _matcher;
    
    beforeEach(^{
        _matcher = [CRDIDefaultPropertyNameMatcher new];
    });
    
    it(@"should detect names wiht default prefix", ^{
        [[theValue([_matcher shouldInject:@"ioc_controller"]) should] beTrue];
    });
    
    it(@"should ignore names wiht default prefix, but without main name part", ^{
        [[theValue([_matcher shouldInject:@"ioc_"]) should] beFalse];
    });
    
    it(@"should ignore names wiht default prefix not in the beginning of property name", ^{
        [[theValue([_matcher shouldInject:@"bla_ioc_test"]) should] beFalse];
    });
    
    it(@"should ignore names wihtout default prefix", ^{
        [[theValue([_matcher shouldInject:@"bla_controller"]) should] beFalse];
    });
});

SPEC_END
