//
//  RACTokenizedStringSequence.h
//  ReactiveCocoa
//
//  Created by Petro Korienev on 6/8/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

#import "RACSequence.h"

@interface RACTokenizedStringSequence : RACSequence

// Returns a sequence for enumerating over the given string by give tokenization.
// The string will be copied to prevent mutation.
+ (instancetype)sequenceWithString:(NSString *)string tokenization:(NSStringEnumerationOptions)tokenization;

@end
