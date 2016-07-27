//
//  ATAboutViewController.m
//  ApptentiveConnect
//
//  Created by Frank Schmitt on 7/28/15.
//  Copyright (c) 2015 Apptentive, Inc. All rights reserved.
//

#import "ATAboutViewController.h"
#import "ATBackend.h"
#import "ATConnect_Private.h"
#import "ATEngagementBackend.h"

NSString *const ATInteractionAboutViewInteractionKey = @"About";
NSString *const ATInteractionAboutViewEventLabelLaunch = @"launch";
NSString *const ATInteractionAboutViewEventLabelClose = @"close";


@interface ATAboutViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboutButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboutButtonPrivacyButtonVeritcalConstraint;


@property (strong, nonatomic) NSArray *portraitConstraints;
@property (strong, nonatomic) NSArray *landscapeConstraints;

@end


@implementation ATAboutViewController

+ (instancetype)aboutViewControllerFromStoryboard {
	return [[ATConnect storyboard] instantiateViewControllerWithIdentifier:@"About"];
}

- (NSString *)codePointForEvent:(NSString *)event {
	return [ATEngagementBackend codePointForVendor:ATEngagementCodePointApptentiveVendorKey interactionType:ATInteractionAboutViewInteractionKey event:event];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[[ATEngagementBackend sharedBackend] engageCodePoint:[self codePointForEvent:ATInteractionAboutViewEventLabelLaunch] fromInteraction:nil userInfo:nil customData:nil extendedData:nil fromViewController:self];

	self.imageView.image = [ATBackend imageNamed:@"at_apptentive_logo"];
	// TODO: Look into localizing the storyboard instead
	self.aboutLabel.text = ATLocalizedString(@"Apptentive is a service that allows you to have a conversation with the makers of this app. Your input and feedback can help to provide you with a better overall experience.\n\nYour feedback is hosted by Apptentive and is subject to both Apptentive’s privacy policy and the privacy policy of this app’s developer.", @"About apptentive introductory message");
	[self.aboutButton setTitle:ATLocalizedString(@"Learn about Apptentive", @"About apptentive link button label") forState:UIControlStateNormal];
	[self.privacyButton setTitle:ATLocalizedString(@"Apptentive’s Privacy Policy", @"About apptentive privacy button label") forState:UIControlStateNormal];

	self.portraitConstraints = @[self.aboutButtonTrailingConstraint, self.privacyButtonLeadingConstraint, self.aboutButtonPrivacyButtonVeritcalConstraint];

	self.landscapeConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[about]-(16)-[privacy]" options:NSLayoutFormatAlignAllBaseline metrics:nil views:@{ @"about": self.aboutButton,
		@"privacy": self.privacyButton }];
}

- (void)viewDidLayoutSubviews {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
	[self resizeForOrientation:self.interfaceOrientation duration:0];
#pragma clang diagnostic pop
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[ATEngagementBackend sharedBackend] engageCodePoint:[self codePointForEvent:ATInteractionAboutViewEventLabelClose] fromInteraction:nil userInfo:nil customData:nil extendedData:nil fromViewController:self];
}

- (IBAction)learnMore:(id)sender {
	NSURLComponents *components = [NSURLComponents componentsWithString:@"http://www.apptentive.com/"];
	components.queryItems = @[[[NSURLQueryItem alloc] initWithName:@"source" value:[NSBundle mainBundle].bundleIdentifier]];

	[[UIApplication sharedApplication] openURL:components.URL];
}

- (IBAction)showPrivacy:(id)sender {
	NSURLComponents *components = [NSURLComponents componentsWithString:@"http://www.apptentive.com/privacy/"];
	components.queryItems = @[[[NSURLQueryItem alloc] initWithName:@"source" value:[NSBundle mainBundle].bundleIdentifier]];

	[[UIApplication sharedApplication] openURL:components.URL];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self resizeForOrientation:toInterfaceOrientation duration:duration];
}

- (void)resizeForOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
	BOOL isCompactHeight = CGRectGetHeight(self.view.bounds) < 400.0;
	BOOL isCompactWidth = CGRectGetWidth(self.view.bounds) < 480.0;

	self.imageViewHeightConstraint.constant = isCompactHeight ? 44.0 : 100.0;
	self.aboutLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.bounds) - 40.0;

	if (isCompactHeight && !isCompactWidth) {
		[self.view removeConstraints:self.portraitConstraints];
		[self.view addConstraints:self.landscapeConstraints];

		self.privacyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	} else {
		[self.view removeConstraints:self.landscapeConstraints];
		[self.view addConstraints:self.portraitConstraints];

		self.privacyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	}

	if (duration > 0) {
		[UIView animateWithDuration:duration animations:^{
			[self.view layoutIfNeeded];
		}];
	}
}

@end
