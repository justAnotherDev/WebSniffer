//
//  WebSnifferLogger.h
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebSniffObject : NSObject

// identifier
@property (nonatomic, readonly) NSString *requestID;

// request data
@property (nonatomic, strong, readonly) NSURL *requestURL;
@property (nonatomic, strong, readonly) NSDictionary *requestHeaders;
@property (nonatomic, strong, readonly) NSArray *requestCookies;
@property (nonatomic, strong, readonly) NSData *postData;

// response data
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) NSString *MIMEType;
@property (nonatomic, readonly) NSStringEncoding serverTextEncoding;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSArray *responseCookies;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSError *responseError;

@end

@interface WebSnifferLogger : NSObject

+(instancetype)sharedInstace;

// data input from the URL protocol
-(NSString*)startedRequest:(NSURLRequest*)aRequest;
-(void)finishedResponse:(NSHTTPURLResponse*)aResponse forIdentifier:(NSString*)aIdentifier;
-(void)finishedData:(NSData*)aData forIdentifier:(NSString*)aIdentifier;
-(void)failedWithError:(NSError*)aError forIdentifier:(NSString*)aIdentifier;

// data requesting
-(NSUInteger)requestCount;
-(NSArray*)allRequests;
-(NSArray*)requestsInRange:(NSRange)aRange;

// data saving
-(BOOL)writeLogToFile:(NSString*)aFilePath;

@end
