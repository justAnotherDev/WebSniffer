//
//  WebSniffLogger.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebSniffLogger.h"

#define kDebugLoud 1

@implementation WebSniffObject

-(NSString*)requestDescription {
	NSMutableString *descriptionString = [NSMutableString string];
	[descriptionString appendString:@"------------- START REQUEST -------------\n\n"];
	[descriptionString appendFormat:@"URL: %@\n", _requestURL];
	if ([_requestHeaders count]) {
		[descriptionString appendFormat:@"Headers: %@\n", _requestHeaders];
	}
	if ([_requestCookies count]) {
		[descriptionString appendFormat:@"Cookies: %@\n", _requestCookies];
	}
	if ([_postData length]) {
		[descriptionString appendFormat:@"Post Data: %@\n", [NSString stringWithUTF8String:[_postData bytes]]];
	}
	[descriptionString appendString:@"\n------------- END REQUEST -------------"];
	
	return descriptionString;
}
-(NSString*)responseDescription {
	NSMutableString *descriptionString = [NSMutableString string];
	[descriptionString appendString:@"------------- START RESPONSE -------------\n\n"];
	[descriptionString appendFormat:@"URL: %@\n", _requestURL];
	if ([_responseHeaders count]) {
		[descriptionString appendFormat:@"Headers: %@\n", _responseHeaders];
	}
	if ([_responseCookies count]) {
		[descriptionString appendFormat:@"Cookies: %@\n", _responseCookies];
	}
	if ([_responseData length]) {
		[descriptionString appendFormat:@"Response: %@\n", [NSString stringWithUTF8String:[_responseData bytes]]];
	}
	[descriptionString appendString:@"\n------------- END RESPONSE -------------"];
	
	return descriptionString;
}
-(NSString*)description {
	return [NSString stringWithFormat:@"\n\n%@\n\n%@", [self requestDescription], [self responseDescription]];
}

-(id)initWithRequest:(NSURLRequest*)aRequest {
	
	self = [super init];
	if (!self)
		return nil;
	
	// generate a random value for the ID
	_requestID = [NSString stringWithFormat:@"%ld", random()];
	
	// set the request data
	_requestHeaders = [aRequest allHTTPHeaderFields];
	_requestCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[aRequest URL]];	
	_requestURL = [aRequest URL];
	
	return self;
}
-(void)setResponse:(NSHTTPURLResponse*)aResponse {
	_responseHeaders = [aResponse allHeaderFields];
	_responseCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[aResponse URL]];
	_statusCode = [aResponse statusCode];
	_MIMEType = [aResponse MIMEType];
	
	// see if the server passed a text encoding back
	CFStringRef cfEncoding = (__bridge CFStringRef)[aResponse textEncodingName];
	if (cfEncoding) {
		_serverTextEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(cfEncoding));
	}
	
	// don't allow no text encoding
	if (!_serverTextEncoding) {
		_serverTextEncoding = NSUTF8StringEncoding;
	}
}
-(void)setResponseData:(NSData *)aResponseData {
	_responseData = aResponseData;
	
	if (kDebugLoud)
		NSLog(@"%@", [self description]);
}
-(void)setResponseError:(NSError *)aResponseError {
	_responseError = aResponseError;
	
	if (kDebugLoud)
		NSLog(@"%@", [self description]);
}
@end


static WebSniffLogger *sharedInstance = nil;
@interface WebSniffLogger()
@property (nonatomic, strong) NSMutableArray *logObjects;
@end

@implementation WebSniffLogger

+(instancetype)sharedInstace {
	if (!sharedInstance) {
		static dispatch_once_t predicate;
		dispatch_once(&predicate, ^{
			sharedInstance = [[self alloc] init];
		});
	}
	
	return sharedInstance;
}

-(id)init {
	self = [super init];
	if (!self)
		return nil;
	
	_logObjects = [NSMutableArray array];
	
	return self;
}

// passed in data from web sniff url protocol
-(NSString*)startedRequest:(NSURLRequest*)aRequest {
	// create a new web sniff object and save it
	WebSniffObject *aSniffObject = [[WebSniffObject alloc] initWithRequest:aRequest];
	[_logObjects addObject:aSniffObject];
	
	// return the id of the new object
	return [aSniffObject requestID];
}
-(void)finishedResponse:(NSHTTPURLResponse *)aResponse forIdentifier:(NSString *)aIdentifier {
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier];
	[finishedSniffObject setResponse:aResponse];
}
-(void)finishedData:(NSData *)aData forIdentifier:(NSString *)aIdentifier {
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier];
	[finishedSniffObject setResponseData:aData];
}
-(void)failedWithError:(NSError *)aError forIdentifier:(NSString *)aIdentifier {
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier];
	[finishedSniffObject setResponseError:aError];
}

// requested data
-(WebSniffObject*)webSniffObjectForIdentifier:(NSString*)aIdentifier {
	WebSniffObject *finishedSniffObject = nil;
	for (WebSniffObject *aSniffObject in _logObjects) {
		if ([aSniffObject.requestID isEqual:aIdentifier]) {
			finishedSniffObject = aSniffObject;
			break;
		}
	}
	
	if (!finishedSniffObject) {
		NSLog(@"this shouldn't happen.. couldn't find the original request");
		return nil;
	}
	return finishedSniffObject;
}
-(NSUInteger)requestCount {
	return [_logObjects count];
}
-(NSArray*)allRequests {
	return [NSArray arrayWithArray:_logObjects];
}
-(NSArray*)requestsInRange:(NSRange)aRange {
	return [_logObjects subarrayWithRange:aRange];
}

// write log to file
-(BOOL)writeLogToFile:(NSString *)aFilePath {
	
	NSMutableString *allRequestsString = [NSMutableString string];
	for (WebSniffObject *aObject in _logObjects) {
		[allRequestsString appendString:[aObject description]];
	}
	
	if (kDebugLoud)
		NSLog(@"attempting to save to: %@", aFilePath);
	
	return [allRequestsString writeToFile:aFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end
