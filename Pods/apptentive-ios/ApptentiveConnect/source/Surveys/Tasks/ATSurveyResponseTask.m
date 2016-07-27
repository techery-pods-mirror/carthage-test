//
//  ATSurveyResponseTask.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 7/8/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATSurveyResponseTask.h"
#import "ATBackend.h"
#import "ATJSONSerialization.h"
#import "ATWebClient+SurveyAdditions.h"

#define kATPendingMessageTaskCodingVersion 1


@interface ATSurveyResponseTask (Private)
- (BOOL)processResult:(NSDictionary *)jsonMessage;
@end


@interface ATSurveyResponseTask ()

@property (strong, nonatomic) ATAPIRequest *request;

@end


@implementation ATSurveyResponseTask

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		int version = [coder decodeIntForKey:@"version"];
		if (version == kATPendingMessageTaskCodingVersion) {
			self.pendingSurveyResponseID = [coder decodeObjectForKey:@"pendingSurveyResponseID"];
		} else {
			return nil;
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kATPendingMessageTaskCodingVersion forKey:@"version"];
	[coder encodeObject:self.pendingSurveyResponseID forKey:@"pendingSurveyResponseID"];
}

- (void)dealloc {
	[self stop];
}

- (BOOL)canStart {
	if ([[ATBackend sharedBackend] apiKey] == nil) {
		return NO;
	}
	if (![ATConversationUpdater conversationExists]) {
		return NO;
	}
	return YES;
}

- (void)start {
	if (!self.request) {
		ATSurveyResponse *response = [ATSurveyResponse findSurveyResponseWithPendingID:self.pendingSurveyResponseID];
		if (response == nil) {
			ATLogError(@"Warning: Response was nil in survey response task.");
			self.finished = YES;
			return;
		}
		self.request = [[ATWebClient sharedClient] requestForPostingSurveyResponse:response];
		if (self.request != nil) {
			self.request.delegate = self;
			[self.request start];
			self.inProgress = YES;
		} else {
			self.finished = YES;
		}
		response = nil;
	}
}

- (void)stop {
	if (self.request) {
		self.request.delegate = nil;
		[self.request cancel];
		self.request = nil;
		self.inProgress = NO;
	}
}

- (float)percentComplete {
	if (self.request) {
		return [self.request percentageComplete];
	} else {
		return 0.0f;
	}
}

- (NSString *)taskName {
	return @"survey response";
}

#pragma mark ATAPIRequestDelegate
- (void)at_APIRequestDidFinish:(ATAPIRequest *)sender result:(NSObject *)result {
	@synchronized(self) {
		if ([result isKindOfClass:[NSDictionary class]] && [self processResult:(NSDictionary *)result]) {
			self.finished = YES;
		} else {
			ATLogError(@"Survey response result is not NSDictionary!");
			self.failed = YES;
		}
		[self stop];
	}
}

- (void)at_APIRequestDidProgress:(ATAPIRequest *)sender {
	// pass
}

- (void)at_APIRequestDidFail:(ATAPIRequest *)sender {
	@synchronized(self) {
		self.lastErrorTitle = sender.errorTitle;
		self.lastErrorMessage = sender.errorMessage;

		ATSurveyResponse *response = [ATSurveyResponse findSurveyResponseWithPendingID:self.pendingSurveyResponseID];
		if (response == nil) {
			ATLogError(@"Warning: Survey response went away during task.");
			self.finished = YES;
			return;
		}

		if (sender.errorResponse != nil) {
			NSError *parseError = nil;
			NSObject *errorObject = [ATJSONSerialization JSONObjectWithString:sender.errorResponse error:&parseError];
			if (errorObject != nil && [errorObject isKindOfClass:[NSDictionary class]]) {
				NSDictionary *errorDictionary = (NSDictionary *)errorObject;
				if ([errorDictionary objectForKey:@"errors"]) {
					ATLogInfo(@"ATAPIRequest server error: %@", [errorDictionary objectForKey:@"errors"]);
				}
			} else if (errorObject == nil) {
				ATLogError(@"Error decoding error response: %@", parseError);
			}
			[response setPendingState:@(ATPendingSurveyResponseError)];
		}
		NSError *error = nil;
		NSManagedObjectContext *context = [[ATBackend sharedBackend] managedObjectContext];
		if (![context save:&error]) {
			ATLogError(@"Failed to save survey response after API failure: %@", error);
		}
		ATLogInfo(@"ATAPIRequest failed: %@, %@", sender.errorTitle, sender.errorMessage);
		if (self.failureCount > 2) {
			self.finished = YES;
		} else {
			self.failed = YES;
		}
		[self stop];
		response = nil;
	}
}
@end


@implementation ATSurveyResponseTask (Private)

- (BOOL)processResult:(NSDictionary *)jsonResponse {
	ATLogDebug(@"Getting json result: %@", jsonResponse);
	NSManagedObjectContext *context = [[ATBackend sharedBackend] managedObjectContext];

	ATSurveyResponse *response = [ATSurveyResponse findSurveyResponseWithPendingID:self.pendingSurveyResponseID];
	if (response == nil) {
		ATLogError(@"Warning: Response went away during task.");
		return YES;
	}
	[response updateWithJSON:jsonResponse];
	response.pendingState = [NSNumber numberWithInt:ATPendingSurveyResponseConfirmed];

	NSError *error = nil;
	if (![context save:&error]) {
		ATLogError(@"Failed to save new response: %@", error);
		response = nil;
		return NO;
	}
	response = nil;
	return YES;
}
@end
