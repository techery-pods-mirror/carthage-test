//
//  ATConversation.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 2/4/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATJSONModel.h"


@interface ATConversation : NSObject <NSCoding, ATJSONModel>
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *personID;
@property (strong, nonatomic) NSString *deviceID;

- (NSDictionary *)apiUpdateJSON;
@end
