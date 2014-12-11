//
//  WebSniffingURLProtocol.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebSniffingURLProtocol.h"
#import "WebSniffLogger.h"

@interface WebSniffingURLProtocol()
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

static NSString *requestKey = @"requestKey";

@implementation WebSniffingURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
 
	if ([NSURLProtocol propertyForKey:requestKey inRequest:request]) {
		return NO;
	}
 
	return YES;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
	// disable all caching
	return NO;
}

- (void)startLoading {
	
	NSMutableURLRequest *request = [self.request mutableCopy];
	
	// alert the logger and save the request's ID (to prevent duplicates and to close the request in the logger)
	NSString *requestID = [[WebSniffLogger sharedInstace] startedRequest:request];
	[NSURLProtocol setProperty:requestID forKey:requestKey inRequest:request];
 
	_mutableData = [NSMutableData data];
	_urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}
- (void)stopLoading {
	[_urlConnection cancel];
	_urlConnection = nil;
	_mutableData = nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
		[[WebSniffLogger sharedInstace] finishedResponse:(NSHTTPURLResponse*)response forIdentifier:requestID];
	}
	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_mutableData appendData:data];
	[self.client URLProtocol:self didLoadData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffLogger sharedInstace] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
	
	[NSURLProtocol removePropertyForKey:requestKey inRequest:[connection.originalRequest mutableCopy]];
	[self.client URLProtocolDidFinishLoading:self];
	
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffLogger sharedInstace] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
	
	
	
	[self.client URLProtocol:self didFailWithError:error];
}




@end
