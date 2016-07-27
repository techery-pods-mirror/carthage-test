//
//  ATRecordRequestTask.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 3/10/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATTask.h"
#import "ATAPIRequest.h"

typedef enum {
	ATRecordRequestTaskFailedResult,
	ATRecordRequestTaskFinishedResult,
} ATRecordRequestTaskResult;

@protocol ATRequestTaskProvider;


@interface ATRecordRequestTask : ATTask <ATAPIRequestDelegate>
@property (strong, nonatomic) NSObject<ATRequestTaskProvider> *taskProvider;
@end


@protocol ATRequestTaskProvider <NSObject>
- (NSURL *)managedObjectURIRepresentationForTask:(ATRecordRequestTask *)task;
- (void)cleanupAfterTask:(ATRecordRequestTask *)task;
- (ATAPIRequest *)requestForTask:(ATRecordRequestTask *)task;
- (ATRecordRequestTaskResult)taskResultForTask:(ATRecordRequestTask *)task withRequest:(ATAPIRequest *)request withResult:(id)result;
@end
