//
//  WebSniffer.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebSniffer.h"

#define kDebugLoud 1

@interface WebSniffObject()
@property (nonatomic, strong) NSInputStream *httpBodyStream;
@property (nonatomic, strong) NSDictionary *curlStatusCodes;
@end

@implementation WebSniffObject

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
	_requestMethod = [aRequest HTTPMethod];
	_postData = [aRequest HTTPBody];
	
	// chunked data post's still not working right
	/*
	_httpBodyStream = [aRequest HTTPBodyStream];
	if (_httpBodyStream) {
		unsigned char *bodyBytes = nil;
		NSUInteger length = 0;
		[_httpBodyStream getBuffer:&bodyBytes length:&length];
		
		if (length && bodyBytes) {
			_postData = [NSData dataWithBytes:bodyBytes length:length];
		}
		NSLog(@"body stream");
	}
	 */
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
		NSLog(@"\n\n%@", [self responseRawString]);
}
-(void)setResponseError:(NSError *)aResponseError {
	_responseError = aResponseError;
	
	if (kDebugLoud)
		NSLog(@"\n\n%@", [self responseRawString]);
}

// customized descriptions
-(NSString*)requestRawString {
	NSMutableString *rawRequestString = [NSMutableString string];
	
	NSString *pathString = [_requestURL path];
	if (!pathString) {
		pathString = @"/";
	}
	[rawRequestString appendFormat:@"%@ %@ HTTP/1.1", _requestMethod, pathString];
	[rawRequestString appendFormat:@"\nHost: %@", [_requestURL host]];
	
	if ([_requestCookies count]) {
		NSMutableString *aCookieString = [NSMutableString string];
		for (NSHTTPCookie *aCookie in _requestCookies) {
			[aCookieString appendFormat:@"%@=%@;", [aCookie name], [aCookie value]];
		}
		[rawRequestString appendFormat:@"\nCookie: %@", aCookieString];
	}
	
	for (NSDictionary *aHeader in [[_requestHeaders allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
		[rawRequestString appendFormat:@"\n%@: %@", aHeader, [_requestHeaders objectForKey:aHeader]];
	}
	
	if ([_postData length]) {
		[rawRequestString appendFormat:@"\n\n%@", [[NSString alloc] initWithData:_postData encoding:NSUTF8StringEncoding]];
	}
	
	return rawRequestString;
}
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

-(NSString*)responseRawString {
	NSMutableString *rawResponseString = [NSMutableString string];
	[rawResponseString appendFormat:@"HTTP/1.1 %ld %@", _statusCode, [self curlStatusString]];

	for (NSDictionary *aHeader in [[_responseHeaders allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
		[rawResponseString appendFormat:@"\n%@: %@", aHeader, [_responseHeaders objectForKey:aHeader]];
	}
	
	if ([_MIMEType hasPrefix:@"text"] && [_responseData length]) {
		[rawResponseString appendFormat:@"\n\n%@", [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]];
	}
	
	return rawResponseString;
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

-(NSString*)curlStatusString {
	if (!_curlStatusCodes)
		_curlStatusCodes = @{@"100":@"Continue", @"101":@"Switching Protocols", @"200":@"OK", @"201":@"Created", @"202":@"Accepted", @"203":@"Non-Authoritative Information", @"204":@"No Content", @"205":@"Reset Content", @"206":@"Partial Content", @"300":@"Multiple Choices", @"301":@"Moved Permanently", @"302":@"Found", @"303":@"See Other", @"304":@"Not Modified", @"305":@"Use Proxy", @"306":@"(Unused)", @"307":@"Temporary Redirect", @"400":@"Bad Request", @"401":@"Unauthorized", @"402":@"Payment Required", @"403":@"Forbidden", @"404":@"Not Found", @"405":@"Method Not Allowed", @"406":@"Not Acceptable", @"407":@"Proxy Authentication Required", @"408":@"Request Timeout", @"409":@"Conflict", @"410":@"Gone", @"411":@"Length Required", @"412":@"Precondition Failed", @"413":@"Request Entity Too Large", @"414":@"Request-URI Too Long", @"415":@"Unsupported Media Type", @"416":@"Requested Range Not Satisfiable", @"417":@"Expectation Failed", @"500":@"Internal Server Error", @"501":@"Not Implemented", @"502":@"Bad Gateway", @"503":@"Service Unavailable", @"504":@"Gateway Timeout", @"505":@"HTTP Version Not Supported"};
	
	
	return [_curlStatusCodes objectForKey:[NSString stringWithFormat:@"%ld", _statusCode]];
}

@end


static WebSniffer *sharedInstance = nil;
@interface WebSniffer()
@property (nonatomic, strong) NSMutableArray *logObjects;
@property (nonatomic, strong) NSMutableArray *delegates;
@end

@implementation WebSniffer

+(instancetype)sharedInstance {
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
	
	_shouldLogRequests = YES;
	_logObjects = [NSMutableArray array];
	
	return self;
}
-(void)addDelegate:(id<WebSnifferDelegate>)delegate {
	if (!_delegates) {
		_delegates = [NSMutableArray array];
	}
	[_delegates addObject:delegate];
}
-(void)removeDelegate:(id<WebSnifferDelegate>)delegate {
	[_delegates removeObject:delegate];
}

// passed in data from web sniff url protocol
-(NSString*)startedRequest:(NSURLRequest*)aRequest {
	// if we are recording then bail (but still need to provide an ID)
	if (!_shouldLogRequests)
		return [NSString stringWithFormat:@"%ld", random()];
	
	// create a new web sniff object and save it
	WebSniffObject *aSniffObject = [[WebSniffObject alloc] initWithRequest:aRequest];
	[_logObjects addObject:aSniffObject];
	
	// alert anyone listening
	for (id <WebSnifferDelegate> aDelegate in _delegates) {
		if ([aDelegate respondsToSelector:@selector(webSniffer:didStartLoading:atIndex:)]) {
			[aDelegate webSniffer:self didStartLoading:aSniffObject atIndex:[_logObjects count]-1];
		}
	}
	
	// return the id of the new object
	return [aSniffObject requestID];
}
-(void)finishedResponse:(NSHTTPURLResponse *)aResponse forIdentifier:(NSString *)aIdentifier {
	// if we are recording then bail
	if (!_shouldLogRequests)
		return;
	
	NSInteger aIndex;
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier atIndex:&aIndex];
	[finishedSniffObject setResponse:aResponse];
	
	// NOT DONE YET, STILL NEED THE DATA
}
-(void)finishedData:(NSData *)aData forIdentifier:(NSString *)aIdentifier {
	// if we are recording then bail
	if (!_shouldLogRequests)
		return;
	
	NSInteger aIndex;
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier atIndex:&aIndex];
	[finishedSniffObject setResponseData:aData];
	
	// alert anyone listening
	for (id <WebSnifferDelegate> aDelegate in _delegates) {
		if ([aDelegate respondsToSelector:@selector(webSniffer:didFinishLoading:atIndex:)]) {
			[aDelegate webSniffer:self didFinishLoading:finishedSniffObject atIndex:aIndex];
		}
	}
}
-(void)failedWithError:(NSError *)aError forIdentifier:(NSString *)aIdentifier {
	// if we are recording then bail
	if (!_shouldLogRequests)
		return;
	
	NSInteger aIndex;
	WebSniffObject *finishedSniffObject = [self webSniffObjectForIdentifier:aIdentifier atIndex:&aIndex];
	[finishedSniffObject setResponseError:aError];
	
	// alert anyone listening
	for (id <WebSnifferDelegate> aDelegate in _delegates) {
		if ([aDelegate respondsToSelector:@selector(webSniffer:didFinishLoading:atIndex:)]) {
			[aDelegate webSniffer:self didFinishLoading:finishedSniffObject atIndex:aIndex];
		}
	}
}

// requested data
-(WebSniffObject*)webSniffObjectForIdentifier:(NSString*)aIdentifier atIndex:(NSInteger*)aIndex {
	*aIndex = 0;
	
	WebSniffObject *finishedSniffObject = nil;
	for (WebSniffObject *aSniffObject in _logObjects) {
		if ([aSniffObject.requestID isEqual:aIdentifier]) {
			finishedSniffObject = aSniffObject;
			break;
		}
		*aIndex += 1;
	}
	
	if (!finishedSniffObject) {
		NSLog(@"this shouldn't happen.. couldn't find the original request");
		*aIndex = -1;
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
-(WebSniffObject*)requestAtIndex:(NSInteger)index {
	return [_logObjects objectAtIndex:index];
}

// data manipulation
-(void)clearLog {
	[_logObjects removeAllObjects];
}
-(void)removeRequestAtIndex:(NSInteger)index {
	[_logObjects removeObjectAtIndex:index];
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
