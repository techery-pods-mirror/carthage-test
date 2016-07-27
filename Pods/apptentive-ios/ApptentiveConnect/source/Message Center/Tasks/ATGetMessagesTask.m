//
//  ATGetMessagesTask.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 10/12/12.
//  Copyright (c) 2012 Apptentive, Inc. All rights reserved.
//

#import "ATGetMessagesTask.h"

#import "ATBackend.h"
#import "ATCompoundMessage.h"
#import "ATConversationUpdater.h"
#import "ATMessageSender.h"
#import "ATWebClient.h"
#import "ATWebClient+MessageCenter.h"
#import "NSDictionary+ATAdditions.h"

static NSString *const ATMessagesLastRetrievedMessageIDPreferenceKey = @"ATMessagesLastRetrievedMessagIDPreferenceKey";


@interface ATGetMessagesTask (Private)
- (BOOL)processResult:(NSDictionary *)jsonMessage;
@end


@implementation ATGetMessagesTask {
	ATAPIRequest *request;
	ATCompoundMessage *lastMessage;
}

- (id)init {
	if ((self = [super init])) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *messageID = [defaults objectForKey:ATMessagesLastRetrievedMessageIDPreferenceKey];
		if (messageID) {
			lastMessage = [ATCompoundMessage findMessageWithID:messageID];
		}
	}
	return self;
}

- (void)dealloc {
	[self stop];
}

- (BOOL)shouldArchive {
	return NO;
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
	if (!request) {
		request = [[ATWebClient sharedClient] requestForRetrievingMessagesSinceMessage:lastMessage];
		if (request != nil) {
			request.delegate = self;
			[request start];
			self.inProgress = YES;
		} else {
			self.finished = YES;
		}
	}
}

- (void)stop {
	if (request) {
		request.delegate = nil;
		[request cancel];
		request = nil;
		self.inProgress = NO;
	}
}

- (float)percentComplete {
	if (request) {
		return [request percentageComplete];
	} else {
		return 0.0f;
	}
}

- (NSString *)taskName {
	return @"getmessages";
}

#pragma mark ATAPIRequestDelegate
- (void)at_APIRequestDidFinish:(ATAPIRequest *)sender result:(NSObject *)result {
	@synchronized(self) {
		UIBackgroundFetchResult fetchResult;

		if ([result isKindOfClass:[NSDictionary class]] && [self processResult:(NSDictionary *)result]) {
			self.finished = YES;
			fetchResult = UIBackgroundFetchResultNewData;
		} else {
			ATLogError(@"Could not process the Get Message Task result!");
			self.failed = YES;
			fetchResult = UIBackgroundFetchResultFailed;
		}
		[self stop];

		[[ATBackend sharedBackend] completeMessageFetchWithResult:fetchResult];
	}
}

- (void)at_APIRequestDidProgress:(ATAPIRequest *)sender {
	// pass
}

- (void)at_APIRequestDidFail:(ATAPIRequest *)sender {
	@synchronized(self) {
		self.failed = YES;
		self.lastErrorTitle = sender.errorTitle;
		self.lastErrorMessage = sender.errorMessage;
		ATLogInfo(@"ATAPIRequest failed: %@, %@", sender.errorTitle, sender.errorMessage);
		[self stop];
	}
}
@end


@implementation ATGetMessagesTask (Private)

- (BOOL)processResult:(NSDictionary *)jsonMessages {
	NSManagedObjectContext *context = [[ATBackend sharedBackend] managedObjectContext];
	NSString *lastMessageID = nil;

	ATConversation *conversation = [ATConversationUpdater currentConversation];

	do { // once
		if (!jsonMessages) break;
		if (![jsonMessages at_safeObjectForKey:@"items"]) break;

		NSArray *messages = [jsonMessages at_safeObjectForKey:@"items"];
		if (![messages isKindOfClass:[NSArray class]]) break;
		if (messages.count > 0) {
			ATLogDebug(@"Apptentive messages: %@", jsonMessages);
		}

		BOOL success = YES;
		for (NSDictionary *messageJSON in messages) {
			NSString *pendingMessageID = [messageJSON at_safeObjectForKey:@"nonce"];
			NSString *messageID = [messageJSON at_safeObjectForKey:@"id"];
			ATCompoundMessage *message = nil;
			message = [ATCompoundMessage findMessageWithPendingID:pendingMessageID];
			if (!message) {
				message = [ATCompoundMessage findMessageWithID:messageID];
			}
			if (!message) {
				message = (ATCompoundMessage *)[ATCompoundMessage newInstanceWithJSON:messageJSON];
				if (conversation && [conversation.personID isEqualToString:message.sender.apptentiveID]) {
					message.sentByUser = @(YES);
					message.seenByUser = @(YES);
				}
				message.pendingState = @(ATPendingMessageStateConfirmed);
				if (message) {
					lastMessageID = messageID;
				}
			} else {
				lastMessageID = messageID;
				[message updateWithJSON:messageJSON];
			}
			if (!message) {
				success = NO;
				break;
			}
		}
		NSError *error = nil;
		if (![context save:&error]) {
			ATLogError(@"Failed to save messages: %@", error);
			success = NO;
		}
		if (success && lastMessageID) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:lastMessageID forKey:ATMessagesLastRetrievedMessageIDPreferenceKey];
			[defaults synchronize];
		}
		return YES;
	} while (NO);
	return NO;
}
@end
