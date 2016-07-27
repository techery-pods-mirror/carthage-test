//
//  ATInteractionRatingDialogController.m
//  ApptentiveConnect
//
//  Created by Peter Kamb on 7/15/15.
//  Copyright (c) 2015 Apptentive, Inc. All rights reserved.
//

#import "ATInteractionRatingDialogController.h"
#import "ATUtilities.h"
#import "ATInteractionInvocation.h"
#import "ATEngagementBackend.h"
#import "ATConnect_Private.h"
#import "ATBackend.h"

NSString *const ATInteractionRatingDialogEventLabelLaunch = @"launch";
NSString *const ATInteractionRatingDialogEventLabelCancel = @"cancel";
NSString *const ATInteractionRatingDialogEventLabelRate = @"rate";
NSString *const ATInteractionRatingDialogEventLabelRemind = @"remind";
NSString *const ATInteractionRatingDialogEventLabelDecline = @"decline";


@implementation ATInteractionRatingDialogController

- (instancetype)initWithInteraction:(ATInteraction *)interaction {
	NSAssert([interaction.type isEqualToString:@"RatingDialog"], @"Attempted to load a RatingDialogController with an interaction of type: %@", interaction.type);

	self = [super init];
	if (self != nil) {
		_interaction = [interaction copy];
	}

	return self;
}

- (NSString *)title {
	NSString *title = self.interaction.configuration[@"title"] ?: ATLocalizedString(@"Thank You", @"Rate app title.");

	return title;
}

- (NSString *)body {
	NSString *body = self.interaction.configuration[@"body"] ?: [NSString stringWithFormat:ATLocalizedString(@"We're so happy to hear that you love %@! It'd be really helpful if you rated us. Thanks so much for spending some time with us.", @"Rate app message. Parameter is app name."), [[ATBackend sharedBackend] appName]];

	return body;
}

- (NSString *)rateText {
	NSString *rateText = self.interaction.configuration[@"rate_text"] ?: [NSString stringWithFormat:ATLocalizedString(@"Rate %@", @"Rate app button title"), [[ATBackend sharedBackend] appName]];

	return rateText;
}

- (NSString *)declineText {
	NSString *declineText = self.interaction.configuration[@"decline_text"] ?: ATLocalizedString(@"No Thanks", @"cancel title for app rating dialog");

	return declineText;
}

- (NSString *)remindText {
	NSString *remindText = self.interaction.configuration[@"remind_text"] ?: ATLocalizedString(@"Remind Me Later", @"Remind me later button title");

	return remindText;
}

- (void)presentRatingDialogFromViewController:(UIViewController *)viewController {
	if (!self.interaction) {
		ATLogError(@"Cannot present a Rating Dialog alert without an interaction.");
		return;
	}

	self.viewController = viewController;

	if ([UIAlertController class]) {
		self.alertController = [self alertControllerWithInteraction:self.interaction];

		if (self.alertController) {
			[viewController presentViewController:self.alertController animated:YES completion:^{
				[self.interaction engage:ATInteractionRatingDialogEventLabelLaunch fromViewController:self.viewController];
			}];
		}
	} else {
		self.alertView = [self alertViewWithInteraction:self.interaction];

		if (self.alertView) {
			[self.alertView show];
		}
	}
}

#pragma mark UIAlertController

- (UIAlertController *)alertControllerWithInteraction:(ATInteraction *)interaction {
	if (!self.title && !self.body) {
		ATLogError(@"Skipping display of Rating Dialog that does not have a title or body.");
		return nil;
	}

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:self.body preferredStyle:UIAlertControllerStyleAlert];

	[alertController addAction:[UIAlertAction actionWithTitle:self.rateText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self.interaction engage:ATInteractionRatingDialogEventLabelRate fromViewController:self.viewController];
	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:self.remindText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self.interaction engage:ATInteractionRatingDialogEventLabelRemind fromViewController:self.viewController];
	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:self.declineText style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		[self.interaction engage:ATInteractionRatingDialogEventLabelDecline fromViewController:self.viewController];
	}]];

	return alertController;
}

#pragma mark UIAlertView

- (UIAlertView *)alertViewWithInteraction:(ATInteraction *)interaction {
	if (!self.title && !self.body) {
		ATLogError(@"Skipping display of Rating Dialog that does not have a title or body.");
		return nil;
	}

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.body delegate:self cancelButtonTitle:self.declineText otherButtonTitles:self.rateText, self.remindText, nil];

	return alertView;
}

#pragma mark UIAlertViewDelegate

- (void)didPresentAlertView:(UIAlertView *)alertView {
	[self.interaction engage:ATInteractionRatingDialogEventLabelLaunch fromViewController:self.viewController];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == self.alertView) {
		if (buttonIndex == 1) { // rate
			[[NSNotificationCenter defaultCenter] postNotificationName:ATAppRatingFlowUserAgreedToRateAppNotification object:nil];

			[self.interaction engage:ATInteractionRatingDialogEventLabelRate fromViewController:self.viewController];
		} else if (buttonIndex == 2) { // remind later
			[self.interaction engage:ATInteractionRatingDialogEventLabelRemind fromViewController:self.viewController];
		} else if (buttonIndex == 0) { // no thanks
			[self.interaction engage:ATInteractionRatingDialogEventLabelDecline fromViewController:self.viewController];
		}
	}
}

- (void)dealloc {
	_alertView.delegate = nil;
}

@end
