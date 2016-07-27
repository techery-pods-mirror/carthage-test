//
//  ATInteractionMessageCenterController.h
//  ApptentiveConnect
//
//  Created by Peter Kamb on 3/3/14.
//  Copyright (c) 2014 Apptentive, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATInteraction.h"


@interface ATInteractionMessageCenterController : NSObject

- (id)initWithInteraction:(ATInteraction *)interaction;
- (void)showMessageCenterFromViewController:(UIViewController *)viewController;

@end
