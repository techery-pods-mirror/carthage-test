#import <UIKit/UIKit.h>

#import "CRDIAutoInjector.h"
#import "CRDIGlobalAutoInjectionStorage.h"
#import "NSObject+AutoInject.h"
#import "CRDITypedefs.h"
#import "CRDIBlockBuilder.h"
#import "CRDIClassBuilder.h"
#import "CRDISingletoneBuilder.h"
#import "CRDIClassInspector.h"
#import "DIClassTemplate.h"
#import "DIPropertyModel.h"
#import "CRDIDefaultPropertyNameMatcher.h"
#import "CRDIPropertyNameMatcher.h"
#import "CRDIConfiguration.h"
#import "CRDIContainer.h"
#import "CRDIException.h"
#import "CRDIInjector.h"
#import "CRDIDependencyBuilder.h"
#import "CRDIErrorHandlerProtocol.h"
#import "CRDIInstanceInjector.h"

FOUNDATION_EXPORT double CriolloKitDIVersionNumber;
FOUNDATION_EXPORT const unsigned char CriolloKitDIVersionString[];

