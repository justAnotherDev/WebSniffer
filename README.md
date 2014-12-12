WebSniffer
==========

View all incoming and outgoing network traffic.


###What's Returned

WebSniffer listens to all network communications and stores each request and response together as a single object. Delegates will be alerted twice for each request, once for the request and once for the response.

```objectivec
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
```


###Trying It Out

A sample iOS project has been included to demonstrate usage. The iOS project is by no means distribuition ready, but shows basic functionality of WebSniffer.


###Including In Your Own Project

* Add WebSniffer and WebSnifferURLProxy to your project.

* Add to your app delegate:
```objectivec
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
	
	// all web traffic will now route through WebSniffer
	[NSURLProtocol registerClass:[WebSnifferURLProtocol class]];
```

* To have a class listen to the network requests it should become a delegate of WebSniffer's sharedInstance.
```objectivec
-(void)startListening {
	[[WebSniffer sharedInstance] addDelegate:self];
}

// called when a request has started
-(void)webSniffer:(WebSniffer*)webSniffer didStartLoading:(WebSniffObject*)aWebObject atIndex:(NSUInteger)requestIndex {
	// Do something with the request info
}

// called when a request has ended
-(void)webSniffer:(WebSniffer*)webSniffer didFinishLoading:(WebSniffObject*)aWebObject atIndex:(NSUInteger)requestIndex {
	// Do something with the response info
}
```

* Stored requests can be accessed by any class using the provided functions. Becoming a delegate is only required if you want notifications of new requests.

```objectivec
-(NSUInteger)requestCount;
-(NSArray*)allRequests;
-(NSArray*)requestsInRange:(NSRange)aRange;
-(WebSniffObject*)requestAtIndex:(NSInteger)index;
```


###Warnings

* WebLogger stores all requests/responses that it receives, which will lead to memory issues if not managed. Use the built in functions to manage the request list.

```objectivec
-(void)clearLog;
-(void)removeRequestAtIndex:(NSInteger)index;
```


###Known Issues

* Chunked data is not handled correctly
* Binary files are not handled correctly
