//
//  ATSurvey.m
//  ApptentiveSurveys
//
//  Created by Andrew Wooster on 11/5/11.
//  Copyright (c) 2011 Apptentive. All rights reserved.
//

#import "ATSurvey.h"

#define kATSurveyStorageVersion 1


@implementation ATSurvey {
	NSMutableArray *_questions;
}

- (id)init {
	if ((self = [super init])) {
		_questions = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		int version = [coder decodeIntForKey:@"version"];
		_questions = [[NSMutableArray alloc] init];
		if (version == kATSurveyStorageVersion) {
			self.responseRequired = [coder decodeBoolForKey:@"responseRequired"];
			self.identifier = [coder decodeObjectForKey:@"identifier"];
			self.name = [coder decodeObjectForKey:@"name"];
			self.surveyDescription = [coder decodeObjectForKey:@"surveyDescription"];
			NSArray *decodedQuestions = [coder decodeObjectForKey:@"questions"];
			if (decodedQuestions) {
				[_questions addObjectsFromArray:decodedQuestions];
			}
			self.showSuccessMessage = [[coder decodeObjectForKey:@"showSuccessMessage"] boolValue];
			self.successMessage = [coder decodeObjectForKey:@"successMessage"];
		} else {
			return nil;
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kATSurveyStorageVersion forKey:@"version"];
	[coder encodeObject:self.identifier forKey:@"identifier"];
	[coder encodeBool:self.responseIsRequired forKey:@"responseRequired"];
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.surveyDescription forKey:@"surveyDescription"];
	[coder encodeObject:self.questions forKey:@"questions"];
	[coder encodeObject:@(self.showSuccessMessage) forKey:@"showSuccessMessage"];
	[coder encodeObject:self.successMessage forKey:@"successMessage"];
}


- (NSString *)description {
	return [NSString stringWithFormat:@"<ATSurvey: %p {name:%@, identifier:%@}>", self, self.name, self.identifier];
}

- (void)addQuestion:(ATSurveyQuestion *)question {
	[_questions addObject:question];
}

- (void)reset {
	for (ATSurveyQuestion *question in self.questions) {
		[question reset];
	}
}

@end
