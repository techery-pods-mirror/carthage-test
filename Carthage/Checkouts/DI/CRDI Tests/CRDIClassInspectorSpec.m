#import <Kiwi.h>
#import "CRDIClassInspector.h"
#import "CRDIInjectedClass.h"

SPEC_BEGIN(CRDIClassInspectorSpec)

describe(@"Class inspection", ^{
    __block CRDIClassInspector *_inspector;
    
    beforeEach(^{
        _inspector = [CRDIClassInspector new];
    });
    
    context(@"Inspection", ^{
        __block DIClassTemplate *_template;
        
        beforeEach(^{
           _template = [_inspector inspect:[CRDIInjectedClass class]];
        });
        
        it(@"should return class template for class", ^{
            [[_template should] beNonNil];
        });
        
        it(@"should return class template with right template class", ^{
            [[_template.templateClass should] equal:[CRDIInjectedClass class]];
        });
        
        it(@"should return class template with properties to inject", ^{
            [[_template.properties should] beNonNil];
            [[_template.properties shouldNot] beEmpty];
            [[_template.properties should] haveCountOf:2];
            
            DIPropertyModel *propetry = _template.properties[0];
            
            [[theValue([propetry.name isEqualToString:@"ioc_injected"]) should] beTrue];
            [[theValue(propetry.protocol == @protocol(CRDISampleProtocol)) should] beTrue];
            
            DIPropertyModel *propetry2 = _template.properties[1];
            
            [[theValue([propetry2.name isEqualToString:@"ioc_testField"]) should] beTrue];
            [[theValue(propetry2.protocol == @protocol(CRDIAnotherSampleProtocol)) should] beTrue];
        });
    });
    
    
});

SPEC_END