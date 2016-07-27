//
//  ATInteractionAppStoreController.h
//  ApptentiveConnect
//
//  Created by Peter Kamb on 3/26/14.
//  Copyright (c) 2014 Apptentive, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@class ATInteraction;


@interface ATInteractionAppStoreController : NSObject
#if TARGET_OS_IPHONE
											 <SKStoreProductViewControllerDelegate, UIAlertViewDelegate>
#endif

@property (readonly, strong, nonatomic) ATInteraction *interaction;
@property (strong, nonatomic) UIViewController *viewController;

- (id)initWithInteraction:(ATInteraction *)interaction;
- (void)openAppStoreFromViewController:(UIViewController *)viewController;

@end
