//
//  ATTask.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 3/20/11.
//  Copyright 2011 Apptentive, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATTask : NSObject <NSCoding>
@property (assign, nonatomic) BOOL inProgress;
@property (assign, nonatomic) BOOL finished;
@property (assign, nonatomic) BOOL failed;
@property (assign, nonatomic) NSUInteger failureCount;

@property (copy, nonatomic) NSString *lastErrorTitle;
@property (copy, nonatomic) NSString *lastErrorMessage;
/*! Should we stop the task queue if this task fails, or just throw it away? Defaults to stopping task queue (failureOkay == NO). */
@property (assign, nonatomic, getter=isFailureOkay) BOOL failureOkay;


- (BOOL)canStart;
- (BOOL)shouldArchive;
- (void)start;
- (void)stop;
/*! Called before we delete this task. */
- (void)cleanup;
- (float)percentComplete;
- (NSString *)taskName;

- (NSString *)taskDescription;
@end
