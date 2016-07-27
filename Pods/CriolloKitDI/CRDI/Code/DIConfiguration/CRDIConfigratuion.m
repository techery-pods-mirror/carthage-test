//
//  CRDIModule.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIConfiguration.h"

@interface CRDIConfiguration ()

@property (nonatomic, weak) CRDIContainer *container;

@property (nonatomic, weak) CRDIConfiguration *parentConfiguration;

@end

@implementation CRDIConfiguration

- (id)initWithContainer:(CRDIContainer *)aContainer
{
    NSParameterAssert(aContainer);
    
    if (![aContainer isKindOfClass:[CRDIContainer class]]) {
        @throw [CRDIException exceptionWithReason:@"aContainer is not a kind of CRDIContainer class"];
    }
    
    self = [super init];
    
    if (self) {
        self.container = aContainer;
    }
    
    return self;
}

- (id)initWithParentConfiguratuion:(CRDIConfiguration *)aConfiguration container:(CRDIContainer *)aContainer
{
    NSParameterAssert(aConfiguration);
    
    self = [self initWithContainer:aContainer];
    
    if (self) {
        self.parentConfiguration = aConfiguration;
        
        [self checkForDependencyLoop];
    }
    
    return self;
}

- (void)configure {}

- (void)includeConfigurationWithClass:(Class)aConfigurationClass
{
    BOOL configurationIsSublcassOfConfigurationClass = [aConfigurationClass isSubclassOfClass:[CRDIConfiguration class]];
    
    if (!configurationIsSublcassOfConfigurationClass) {
        @throw [CRDIException exceptionWithReason:@"configurationClass is not subclass of CRDIConfiguration class"];
    }
    
    CRDIConfiguration *configuration = [[aConfigurationClass alloc] initWithParentConfiguratuion:self container:self.container];
    
    [configuration configure];
}

- (void)checkForDependencyLoop
{
    CRDIConfiguration *configuration = self.parentConfiguration;
    
    while (configuration) {
        if ([configuration isKindOfClass:[self class]]) {
            @throw [CRDIException exceptionWithReason:@"Parent module isKind of received module"];
        }
        configuration = configuration.parentConfiguration;
    }
}

@end
