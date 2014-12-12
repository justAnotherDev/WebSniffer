//
//  WebSniffer.h
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebSniffer;
@class WebSniffObject;
@protocol WebSnifferDelegate <NSObject>
-(void)webSniffer:(WebSniffer*)webSniffer didStartLoading:(WebSniffObject*)aWebObject atIndex:(NSUInteger)requestIndex;
-(void)webSniffer:(WebSniffer*)webSniffer didFinishLoading:(WebSniffObject*)aWebObject atIndex:(NSUInteger)requestIndex;
@end

@interface WebSniffer : NSObject

// BOOL value to enable/disable logging
@property (nonatomic, assign) BOOL shouldLogRequests;

+(instancetype)sharedInstance;

// data input from the URL protocol
-(NSString*)startedRequest:(NSURLRequest*)aRequest;
-(void)finishedResponse:(NSHTTPURLResponse*)aResponse forIdentifier:(NSString*)aIdentifier;
-(void)finishedData:(NSData*)aData forIdentifier:(NSString*)aIdentifier;
-(void)failedWithError:(NSError*)aError forIdentifier:(NSString*)aIdentifier;

// data listening
-(void)addDelegate:(id <WebSnifferDelegate>)delegate;
-(void)removeDelegate:(id <WebSnifferDelegate>)delegate;

// data requesting
-(NSUInteger)requestCount;
-(NSArray*)allRequests;
-(NSArray*)requestsInRange:(NSRange)aRange;
-(WebSniffObject*)requestAtIndex:(NSInteger)index;

// data manipulation
-(void)clearLog;
-(void)removeRequestAtIndex:(NSInteger)index;

// data saving
-(BOOL)writeLogToFile:(NSString*)aFilePath;

@end


@interface WebSniffObject : NSObject

// identifier
@property (nonatomic, readonly) NSString *requestID;

// request information
@property (nonatomic, strong, readonly) NSURL *requestURL;
@property (nonatomic, strong, readonly) NSString *requestMethod;
@property (nonatomic, strong, readonly) NSDictionary *requestHeaders;
@property (nonatomic, strong, readonly) NSArray *requestCookies;
@property (nonatomic, strong, readonly) NSData *postData;
@property (nonatomic, strong, readonly) NSString *requestRawString;

// response information
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) NSString *MIMEType;
@property (nonatomic, readonly) NSStringEncoding serverTextEncoding;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSArray *responseCookies;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSError *responseError;
@property (nonatomic, strong, readonly) NSString *responseRawString;

@end