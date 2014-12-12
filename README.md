WebSniffer
==========

View all incoming and outgoing traffic.

###Including In Your Own Project

* Add WebSniffer and WebSnifferURLProxy to your project.

* Add to your app delegate:
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// all web traffic will now route through WebSniffer
	[NSURLProtocol registerClass:[WebSnifferURLProtocol class]];
```

* To have a class listen to the network requests have it become a delegate of WebSniffer's sharedInstance.
```
- (void)startListening {
	[[WebSniffer sharedInstance] addDelegate:self];
}

// called when a request has started
-(void)webSniffer:(WebSniffer *)webSniffer didStartLoading:(WebSniffObject *)aWebObject atIndex:(NSUInteger)requestIndex {
	// Do something with the request info
}

// called when a request has ended
-(void)webSniffer:(WebSniffer *)webSniffer didFinishLoading:(WebSniffObject *)aWebObject atIndex:(NSUInteger)requestIndex {
	// Do something with the response info
}
```
