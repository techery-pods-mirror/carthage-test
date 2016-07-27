//
//  ATInteraction.h
//  ApptentiveConnect
//
//  Created by Peter Kamb on 8/23/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATInteractionUsageData;

typedef NS_ENUM(NSInteger, ATInteractionType) {
	ATInteractionTypeUnknown,
	ATInteractionTypeUpgradeMessage,
	ATInteractionTypeEnjoymentDialog,
	ATInteractionTypeRatingDialog,
	ATInteractionTypeMessageCenter,
	ATInteractionTypeAppStoreRating,
	ATInteractionTypeSurvey,
	ATInteractionTypeTextModal,
	ATInteractionTypeNavigateToLink,
};


@interface ATInteraction : NSObject <NSCoding, NSCopying>
@property (copy, nonatomic) NSString *identifier;
@property (assign, nonatomic) NSInteger priority;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSDictionary *configuration;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *vendor;

+ (ATInteraction *)interactionWithJSONDictionary:(NSDictionary *)jsonDictionary;

// Used to engage local and app events
+ (ATInteraction *)localAppInteraction;
+ (ATInteraction *)apptentiveAppInteraction;

- (ATInteractionType)interactionType;

- (NSString *)codePointForEvent:(NSString *)event;

- (BOOL)engage:(NSString *)event fromViewController:(UIViewController *)viewController;
- (BOOL)engage:(NSString *)event fromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;
- (BOOL)engage:(NSString *)event fromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo customData:(NSDictionary *)customData extendedData:(NSArray *)extendedData;

@end
