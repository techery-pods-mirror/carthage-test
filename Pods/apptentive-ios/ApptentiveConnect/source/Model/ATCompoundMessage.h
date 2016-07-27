//
//  ATCompoundMessage.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 10/6/12.
//  Copyright (c) 2012 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <QuickLook/QuickLook.h>

#import "ATJSONModel.h"
#import "ATRecord.h"

typedef NS_ENUM(NSInteger, ATPendingMessageState) {
	ATPendingMessageStateNone = -1,
	ATPendingMessageStateComposing = 0,
	ATPendingMessageStateSending,
	ATPendingMessageStateConfirmed,
	ATPendingMessageStateError
};

@class ATMessageDisplayType, ATMessageSender;


@interface ATCompoundMessage : ATRecord <ATJSONModel>

@property (strong, nonatomic) NSString *pendingMessageID;
@property (strong, nonatomic) NSNumber *pendingState;
@property (strong, nonatomic) NSNumber *priority;
@property (strong, nonatomic) NSNumber *seenByUser;
@property (strong, nonatomic) NSNumber *sentByUser;
@property (strong, nonatomic) NSNumber *errorOccurred;
@property (strong, nonatomic) NSString *errorMessageJSON;
@property (strong, nonatomic) ATMessageSender *sender;
@property (strong, nonatomic) NSData *customData;
@property (strong, nonatomic) NSNumber *hidden;
@property (strong, nonatomic) NSNumber *automated;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSOrderedSet *attachments;

+ (instancetype)newInstanceWithBody:(NSString *)body attachments:(NSArray *)attachments;
+ (void)clearComposingMessages;
+ (ATCompoundMessage *)findMessageWithID:(NSString *)apptentiveID;
+ (ATCompoundMessage *)findMessageWithPendingID:(NSString *)pendingID;
- (NSArray *)errorsFromErrorMessage;

@end


@interface ATCompoundMessage (CoreDataGeneratedAccessors)

- (void)setCustomDataValue:(id)value forKey:(NSString *)key;
- (void)addCustomDataFromDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryForCustomData;
- (NSData *)dataForDictionary:(NSDictionary *)dictionary;

- (NSNumber *)creationTimeForSections;

- (void)markAsRead;

@end


@interface ATCompoundMessage (QuickLook) <QLPreviewControllerDataSource>
@end
