//
//  CRDIContainer.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIContainer.h"

#import "CRDIClassBuilder.h"
#import "CRDIBlockBuilder.h"
#import "CRDISingletoneBuilder.h"

static CRDIContainer *defaultContainer = nil;

@interface CRDIContainer ()

@property (nonatomic, strong) NSMutableDictionary *configurationDictionary;

@end

@implementation CRDIContainer

+ (CRDIContainer *)defaultContainer
{
    
    return defaultContainer;
}

+ (void)setDefaultContainer:(CRDIContainer *)aContainer
{
    defaultContainer = aContainer;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.configurationDictionary = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)bindClass:(Class)aClass toProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aClass);
    NSParameterAssert(aProtocol);
    
    [self checkIfBuilderForClass:aClass alreadyExistsForProtocol:aProtocol];
    
    CRDIClassBuilder *classBuilder = [self classBuilderFromClass:aClass];
    
    [self addClassBuilder:classBuilder forProtocol:aProtocol];
}

- (void)bindBlock:(CRDIContainerBindBlock)aBlock toProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aBlock);
    NSParameterAssert(aProtocol);
    
    [self checkIfProtocolAlreadyBinded:aProtocol];
    
    CRDIBlockBuilder *blockBuilder = [self blockBuilderFromBlock:aBlock];
    
    [self addClassBuilder:blockBuilder forProtocol:aProtocol];
}

- (void)bindEagerSingletoneClass:(Class)aClass toProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aClass);
    NSParameterAssert(aProtocol);
    
    [self checkIfProtocolAlreadyBinded:aProtocol];
    
    CRDISingletoneBuilder *eaggerSingletoneWithClassBuilder = [self eagerSingletoneBuilderForClass:aClass];
    
    [self addBuilder:eaggerSingletoneWithClassBuilder forProtocol:aProtocol];
}

- (void)bindEagerSingletoneBlock:(CRDIContainerBindBlock)aBlock toProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aBlock);
    NSParameterAssert(aProtocol);
    
    [self checkIfProtocolAlreadyBinded:aProtocol];
    
    CRDISingletoneBuilder *eagerSingletoneWithBlockbuilder = [self eagerSingletoneBuilderForBlock:aBlock];
    
    [self addBuilder:eagerSingletoneWithBlockbuilder forProtocol:aProtocol];
}

- (void)addBuilder:(id <CRDIDependencyBuilder>)aBuilder forProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aBuilder);
    NSParameterAssert(aProtocol);
    
    NSString *protocolKey = [self stringFromPorotocol:aProtocol];
    
    self.configurationDictionary[protocolKey] = aBuilder;
}

- (void)addClassBuilder:(id <CRDIDependencyBuilder>)aBuilder forProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aBuilder);
    NSParameterAssert(aProtocol);
    
    NSString *protocolKey = [self stringFromPorotocol:aProtocol];
    
    NSMutableArray *buildersArray = self.configurationDictionary[protocolKey];
    
    if (!buildersArray) {
        buildersArray = [NSMutableArray arrayWithObject:aBuilder];
    } else {
        [buildersArray addObject:aBuilder];
    }
    
    self.configurationDictionary[protocolKey] = buildersArray;
}

- (id <CRDIDependencyBuilder>)builderForProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aProtocol);
    
    [self checkIfProtocolNotBinded:aProtocol];
    
    NSString *protocolKey = [self stringFromPorotocol:aProtocol];
    
    id builderWrapper = self.configurationDictionary[protocolKey];
    
    if ([builderWrapper isKindOfClass:[NSArray class]]) {
        return [builderWrapper lastObject];
    } else if ([builderWrapper conformsToProtocol:@protocol(CRDIDependencyBuilder)]) {
        return builderWrapper;
    }
    
    [CRDIException exceptionWithReason:@"Wrong builder class"];
    
    return nil;
}

- (NSArray *)buidersForProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aProtocol);
    
    [self checkIfProtocolNotBinded:aProtocol];
    
    NSString *protocolKey = NSStringFromProtocol(aProtocol);
    
    NSArray *buildersArray = self.configurationDictionary[protocolKey];
    
    if (![buildersArray isKindOfClass:[NSArray class]]) {
        [CRDIException exceptionWithReason:[NSString stringWithFormat:@"Not found builders array for protocol: %@", protocolKey]];
    }
    
    return buildersArray;

}

- (CRDIClassBuilder *)classBuilderFromClass:(Class)aClass
{
    return [[CRDIClassBuilder alloc] initWithClass:aClass];
}

- (CRDIBlockBuilder *)blockBuilderFromBlock:(CRDIContainerBindBlock)aBlock
{
    return [[CRDIBlockBuilder alloc] initWithBlock:aBlock];
}

- (CRDISingletoneBuilder *)eagerSingletoneBuilderForClass:(Class)aClass
{
    CRDIClassBuilder *classBuilder = [self classBuilderFromClass:aClass];
    
    return [[CRDISingletoneBuilder alloc] initWithBuilder:classBuilder];
}

- (CRDISingletoneBuilder *)eagerSingletoneBuilderForBlock:(CRDIContainerBindBlock)aBlock
{
    CRDIBlockBuilder *blockBuilder = [self blockBuilderFromBlock:aBlock];
    
    return [[CRDISingletoneBuilder alloc] initWithBuilder:blockBuilder];
}

- (void)checkIfBuilderForClass:(Class)aClass alreadyExistsForProtocol:(Protocol *)aProtocol
{
    NSString *protocolKey = NSStringFromProtocol(aProtocol);
    
    NSArray *buildersArray = self.configurationDictionary[protocolKey];
    
    for (CRDIClassBuilder *classBuilder in buildersArray) {
        if (classBuilder.classForBuild == aClass) {
            [CRDIException exceptionWithReason:[NSString stringWithFormat:@"builders array already contains builder for %@ class", NSStringFromClass(aClass)]];
        }
    }
}

- (void)checkIfProtocolAlreadyBinded:(Protocol *)aProtocol
{
    if ([self protocolIsBinded:aProtocol]) {
        @throw [CRDIException exceptionWithReason:[NSString stringWithFormat:@"Builder for protocol %@ already binded", [self stringFromPorotocol:aProtocol]]];
    }
}

- (void)checkIfProtocolNotBinded:(Protocol *)aProtocol
{
    if (![self protocolIsBinded:aProtocol]) {
        @throw [CRDIException exceptionWithReason:[NSString stringWithFormat:@"Builder for protocol %@ is not binded", [self stringFromPorotocol:aProtocol]]];
    }
}

- (BOOL)protocolIsBinded:(Protocol *)aProtocol
{
    NSString *protocolKey = [self stringFromPorotocol:aProtocol];
    
    return self.configurationDictionary[protocolKey] != nil;
}

- (NSString *)stringFromPorotocol:(Protocol *)aProtocol
{
    return NSStringFromProtocol(aProtocol);
}

@end
