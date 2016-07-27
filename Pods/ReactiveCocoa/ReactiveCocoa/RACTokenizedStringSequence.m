//
//  RACTokenizedStringSequence.m
//  ReactiveCocoa
//
//  Created by Petro Korienev on 6/8/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

#import "RACTokenizedStringSequence.h"

@interface RACTokenizedStringSequence ()

@property (nonatomic, assign) NSStringEnumerationOptions tokenization;
@property (nonatomic, strong) NSString *headString;
@property (nonatomic, strong) NSString *tailString;

@end

@implementation RACTokenizedStringSequence

#pragma mark Lifecycle

+ (instancetype)sequenceWithString:(NSString *)string tokenization:(NSStringEnumerationOptions)tokenization {
    
    if (!string.length) return self.empty;
    __block NSString *head = nil;
    __block NSString *tail = nil;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:tokenization
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if (!head) {   // first iteration
                                         head = substring;
                                     }
                                     else { //second iteration
                                         tail = [string substringWithRange:NSMakeRange(substringRange.location, string.length - substringRange.location)];
                                         *stop = YES;
                                     }
    }];
    
    RACTokenizedStringSequence *seq = [self new];
    seq.headString = head;
    seq.tailString = tail;
    seq.tokenization = tokenization;
    return seq;
}

#pragma mark RACSequence

- (id)head {
    return self.headString;
}

- (RACSequence *)tail {
    RACSequence *sequence = [self.class sequenceWithString:self.tailString tokenization:self.tokenization];
    sequence.name = self.name;
    return sequence;
}

- (NSArray *)array {
    NSMutableArray *array = [NSMutableArray arrayWithObject:self.headString];
    
    [self.tailString enumerateSubstringsInRange:NSMakeRange(0, self.tailString.length)
                                    options:self.tokenization
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [array addObject:substring];
    }];
    
    return [array copy];
}

#pragma mark NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ name = %@, string = %@ }", self.class, self, self.name, [self.headString stringByAppendingString:self.tailString]];
}


@end
