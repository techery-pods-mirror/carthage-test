//
//  ATMessageCenterGreetingView.m
//  ApptentiveConnect
//
//  Created by Frank Schmitt on 5/20/15.
//  Copyright (c) 2015 Apptentive, Inc. All rights reserved.
//

#import "ATMessageCenterGreetingView.h"
#import "ATNetworkImageIconView.h"
#import <QuartzCore/QuartzCore.h>

#define GREETING_PORTRAIT_HEIGHT 258.0
#define GREETING_LANDSCAPE_HEIGHT 128.0


@interface ATMessageCenterGreetingView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCenterYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textCenterYConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBorderHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *textContainerView;

@end


@implementation ATMessageCenterGreetingView

- (void)awakeFromNib {
	self.bottomBorderHeightConstraint.constant = 1.0 / [UIScreen mainScreen].scale;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
	_orientation = orientation;
	[self updateConstraints];
	[self sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size {
	if (UIInterfaceOrientationIsLandscape(self.orientation)) {
		return CGSizeMake(size.width, GREETING_LANDSCAPE_HEIGHT);
	} else {
		return CGSizeMake(size.width, GREETING_PORTRAIT_HEIGHT);
	}
}

- (void)updateConstraints {
	if (UIInterfaceOrientationIsLandscape(self.orientation)) {
		// Landscape on phone: Center vertically, offset horizontally
		self.imageCenterYConstraint.constant = 0.0;
		self.textCenterYConstraint.constant = 0.0;

		self.imageCenterXConstraint.constant = self.textWidthConstraint.constant / 2.0;
		self.textCenterXConstraint.constant = -self.imageWidthConstraint.constant / 2.0;
	} else {
		// Portrait/iPad: Center horizontally, offset vertically
		self.imageCenterXConstraint.constant = 0.0;
		self.textCenterXConstraint.constant = 0.0;

		self.imageCenterYConstraint.constant = self.textContainerView.bounds.size.height / 2.0 + 5.0;
		self.textCenterYConstraint.constant = -self.imageWidthConstraint.constant / 2.0 - 7.0;
	}

	[super updateConstraints];
}

@end
