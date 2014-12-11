//
//  WebSniffingURLProtocol.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebSniffingURLProtocol.h"
#import "WebSniffer.h"

@interface WebSniffingURLProtocol()
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

static NSString *requestKey = @"requestKey";

@implementation WebSniffingURLProtocol

// required abstract methods
+(BOOL)canInitWithRequest:(NSURLRequest *)request {
	// only perform each request once
	if ([NSURLProtocol propertyForKey:requestKey inRequest:request]) {
		return NO;
	}
	return YES;
}
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

// disable all caching
+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
	return NO;
}

// request status change
-(void)startLoading {
	// get the request
	NSMutableURLRequest *request = [self.request mutableCopy];
	
	// alert the logger and save the request's ID (to prevent duplicates and to close the request in the logger)
	NSString *requestID = [[WebSniffer sharedInstace] startedRequest:request];
	[NSURLProtocol setProperty:requestID forKey:requestKey inRequest:request];
 
	_mutableData = [NSMutableData data];
	_urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)stopLoading {
	// cleanup
	[_urlConnection cancel];
	_urlConnection = nil;
	_mutableData = nil;
}

// connection handler
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// update whomever is performing the request
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
	// alert the logger
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
		[[WebSniffer sharedInstace] finishedResponse:(NSHTTPURLResponse*)response forIdentifier:requestID];
	}
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// update whomever is performing the request
	[self.client URLProtocol:self didLoadData:data];
	
	// append the data
	[_mutableData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// update whomever is performing the request
	[self.client URLProtocolDidFinishLoading:self];
	
	// alert the logger
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffer sharedInstace] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
	
	// remove the reference key
	[NSURLProtocol removePropertyForKey:requestKey inRequest:[connection.originalRequest mutableCopy]];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// update whomever is performing the request
	[self.client URLProtocol:self didFailWithError:error];
	
	// alert the logger
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffer sharedInstace] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
}




@end
