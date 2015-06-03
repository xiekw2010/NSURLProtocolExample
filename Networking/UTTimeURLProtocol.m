//
//  UTTimeURLProtocol.m
//  Networking
//
//  Created by xiekw on 15/5/15.
//  Copyright (c) 2015年 隐风. All rights reserved.
//

#import "UTTimeURLProtocol.h"

static NSString * pk = @"UTTimeURLProtocol";

@interface UTTimeURLProtocol () {
    CFAbsoluteTime _startTime;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mData;

@end

@implementation UTTimeURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    id prop = [NSURLProtocol propertyForKey:pk inRequest:request];
    if (prop) return NO;
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *mReq = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:pk inRequest:mReq];
    
    _startTime = CFAbsoluteTimeGetCurrent();
    self.connection = [[NSURLConnection alloc] initWithRequest:mReq delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.mData = [NSMutableData new];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mData appendData:data];
    [self.client URLProtocol:self didLoadData:self.mData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    CFAbsoluteTime timeComsume = CFAbsoluteTimeGetCurrent() - _startTime;
    NSLog(@"URLReq %@ takes %.2f", self.request.URL, timeComsume);
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
    self.mData = nil;
}

@end
