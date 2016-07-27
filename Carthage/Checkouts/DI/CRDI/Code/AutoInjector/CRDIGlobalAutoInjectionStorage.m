//
//  CRDIGlobalAutoInjectorStorage.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIGlobalAutoInjectionStorage.h"

@interface CRDIGlobalAutoInjectionStorage ()

@property (nonatomic, strong) NSMapTable *storageTable;

@end

@implementation CRDIGlobalAutoInjectionStorage

+ (CRDIGlobalAutoInjectionStorage *)storage
{
    static CRDIGlobalAutoInjectionStorage *sharedStorage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [CRDIGlobalAutoInjectionStorage new];
    });
    
    return sharedStorage;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.storageTable = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn
                                                  valueOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (NSString*)put:(id <CRDIInstanceInjector>)injector
{
    NSString *key = [NSString stringWithFormat:@"%d", (NSInteger)injector];
    
    [self.storageTable setObject:injector forKey:key];
    
    return key;
}

- (id <CRDIInstanceInjector>)get:(NSString*)key
{
    return [self.storageTable objectForKey:key];
}

@end
