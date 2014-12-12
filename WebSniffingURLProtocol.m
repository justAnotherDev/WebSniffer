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
	
	// alert the logger and save the request's ID (to prevent duplicates and to close the request in the logger)
	NSString *requestID = [[WebSniffer sharedInstance] startedRequest:self.request];
	[NSURLProtocol setProperty:requestID forKey:requestKey inRequest:(NSMutableURLRequest*)self.request];
 
	_mutableData = [NSMutableData data];
	_urlConnection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}
-(void)stopLoading {
	// cleanup
	[_urlConnection cancel];
	_urlConnection = nil;
	_mutableData = nil;
}

// connection handler
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	// alert the logger
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		
		
		NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
		[[WebSniffer sharedInstance] finishedResponse:(NSHTTPURLResponse*)response forIdentifier:requestID];
		
		
		NSData *bodyData = [[connection currentRequest] HTTPBody];
		if (bodyData) {
			[[WebSniffer sharedInstance] finishedResponse:(NSHTTPURLResponse*)response forIdentifier:requestID];
			
		}
	}
	
	// update whomever is performing the request
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// append the data
	[_mutableData appendData:data];
	
	// update whomever is performing the request
	[self.client URLProtocol:self didLoadData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// alert the logger
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffer sharedInstance] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
	
	// remove the reference key
	[NSURLProtocol removePropertyForKey:requestKey inRequest:(NSMutableURLRequest*)connection.originalRequest];
	
	
	// update whomever is performing the request
	[self.client URLProtocolDidFinishLoading:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	// alert the logger
	NSString *requestID = [NSURLProtocol propertyForKey:requestKey inRequest:connection.originalRequest];
	[[WebSniffer sharedInstance] finishedData:[NSData dataWithData:_mutableData] forIdentifier:requestID];
	
	// update whomever is performing the request
	[self.client URLProtocol:self didFailWithError:error];
}




@end
