//
//  ATURLConnection.h
//
//  Created by Andrew Wooster on 12/14/08.
//  Copyright 2008 Apptentive, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ATURLConnectionDelegate;


@interface ATURLConnection : NSObject
@property (readonly, copy, nonatomic) NSURL *targetURL;
@property (weak, nonatomic) NSObject<ATURLConnectionDelegate> *delegate;
@property (strong, nonatomic) NSURLConnection *connection;
@property (assign, nonatomic) BOOL executing;
@property (assign, nonatomic) BOOL finished;
@property (assign, nonatomic) BOOL failed;
@property (readonly, nonatomic) BOOL cancelled;
@property (assign, nonatomic) NSTimeInterval timeoutInterval;
@property (strong, nonatomic) NSURLCredential *credential;
@property (readonly, nonatomic) NSInteger statusCode;
@property (readonly, nonatomic) BOOL failedAuthentication;
@property (copy, nonatomic) NSError *connectionError;
@property (assign, nonatomic) float percentComplete;
@property (readonly, nonatomic) NSTimeInterval expiresMaxAge;

@property (strong, nonatomic) NSData *HTTPBody;
@property (strong, nonatomic) NSString *HTTPMethod;

/*! The delegate for this class is a weak reference. */
- (id)initWithURL:(NSURL *)url delegate:(NSObject<ATURLConnectionDelegate> *)aDelegate;
- (id)initWithURL:(NSURL *)url;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)removeHTTPHeaderField:(NSString *)field;

- (void)start;

- (BOOL)isExecuting;
- (BOOL)isCancelled;
- (BOOL)isFinished;
/*! A localized description of the response status code. */
- (NSString *)statusLine;
/*! The response headers. */
- (NSDictionary *)responseHeaders;
- (NSData *)responseData;

/*! The request headers. */
- (NSDictionary *)headers;

#pragma mark Debugging
- (NSString *)requestAsString;
- (NSString *)responseAsString;
@end


@protocol ATURLConnectionDelegate <NSObject>
- (void)connectionFinishedSuccessfully:(ATURLConnection *)sender;
- (void)connectionFailed:(ATURLConnection *)sender;
- (void)connectionDidProgress:(ATURLConnection *)sender;
@end
