//
//  ATSurveyResponseTask.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 7/8/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATTask.h"
#import "ATAPIRequest.h"
#import "ATSurveyResponse.h"


@interface ATSurveyResponseTask : ATTask <ATAPIRequestDelegate>
@property (strong, nonatomic) NSString *pendingSurveyResponseID;
@end
