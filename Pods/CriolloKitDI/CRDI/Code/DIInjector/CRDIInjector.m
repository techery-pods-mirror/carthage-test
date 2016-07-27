//
//  CRDIInjector.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIInjector.h"
#import "DIClassTemplate.h"
#import "CRDIClassInspector.h"

static CRDIInjector *sDefaultInjector = nil;

@interface CRDIInjector ()

@property (nonatomic, weak) CRDIContainer *container;
@property (nonatomic, strong) NSMutableDictionary *classesCache;
@property (nonatomic, strong) CRDIClassInspector *classInspector;

@end

@implementation CRDIInjector

+ (CRDIInjector *)defaultInjector
{
    return sDefaultInjector;
}

+ (void)setDefaultInjector:(CRDIInjector *)aDefaultInjector
{
    sDefaultInjector = aDefaultInjector;
}

- (id)init
{
    NSAssert(NO, @"Use initWithContainer: instead");
    return nil;
}

- (id)initWithContainer:(CRDIContainer *)aContainer
{
    NSParameterAssert(aContainer);
    self = [super init];
    
    if (self) {
        self.container = aContainer;
        self.classInspector = [CRDIClassInspector new];
        self.classesCache = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)injectTo:(id)aInstance
{
    NSParameterAssert(aInstance);
    NSParameterAssert(self.classesCache);
    
    DIClassTemplate *cachedClassTeamplate = [self classTemplateForInstance:aInstance];
    
    for (DIPropertyModel *propertyModel in cachedClassTeamplate.properties) {
        if (!propertyModel.protocol) {
            NSLog(@"Warrning: Protocol not found for property: %@", propertyModel.name);
            continue;
        }
        
        id <CRDIDependencyBuilder> builder = [self.container builderForProtocol:propertyModel.protocol];
        
        if (!builder) {
            continue;
        }
        
        id buildedObject = [builder build];

        if ([aInstance respondsToSelector:NSSelectorFromString(propertyModel.name)]) {
            [aInstance setValue:buildedObject forKey:propertyModel.name];
        }
        else {
            NSString *errorReason = [NSString stringWithFormat:@"Injector tries to inject `%@` property to %@ class which not responds to this selector.\n*Parsed class properties: %@.\n*Injected model %@", propertyModel.name, NSStringFromClass([aInstance class]), cachedClassTeamplate.properties, NSStringFromClass([buildedObject class])];
            NSError *error = [NSError errorWithDomain:@"CRDIError" code:500 userInfo:@{NSLocalizedDescriptionKey : errorReason}];
            [self.errorHandler handleError:error];
        }
    }
}

- (DIClassTemplate *)classTemplateForInstance:(id)aInstance
{
    NSString *className = NSStringFromClass([aInstance class]);
    
    DIClassTemplate *cachedClassTeamplate = self.classesCache[className];
    
    if (cachedClassTeamplate == nil) {
        cachedClassTeamplate = [self.classInspector inspect:[aInstance class]];
        self.classesCache[className] = cachedClassTeamplate;
    }
    return cachedClassTeamplate;
}

@end
