//
//  NSString+RACSequenceAdditions.m
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2012-10-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSString+RACSequenceAdditions.h"
#import "RACStringSequence.h"
#import "RACTokenizedStringSequence.h"

@implementation NSString (RACSequenceAdditions)

- (RACSequence *)rac_sequence {
	return [RACStringSequence sequenceWithString:self offset:0];
}

- (RACSequence *)rac_lineSequence {
    return [self rac_sequenceWithTokenization:NSStringEnumerationByLines];
}

- (RACTokenizedStringSequence *)rac_sequenceWithTokenization:(NSStringEnumerationOptions)tokenization {
    return [RACTokenizedStringSequence sequenceWithString:self tokenization:tokenization];
}

@end
