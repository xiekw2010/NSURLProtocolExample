//
//  TestURLProtocol.m
//  Networking
//
//  Created by xiekw on 15/5/15.
//  Copyright (c) 2015年 隐风. All rights reserved.
//

#import "TestURLProtocol.h"
#import "TestURLProtocolCache.h"

static NSString *kProtocolKey = @"handled";

@interface TestURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mData;
@property (nonatomic, strong) NSURLResponse *internalResponse;

@end

@implementation TestURLProtocol
{
    NSString *_cacheKey;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    id prop = [NSURLProtocol propertyForKey:kProtocolKey inRequest:request];
    if (prop) return NO;

    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    return request;
}

- (void)startLoading {
    
    TestURLProtocolCache *cache = [TestURLProtocolCache sharedCache];
    _cacheKey = [TestURLProtocolCache cacheKeyForURL:self.request.URL];
    
    BOOL shouldLoad = YES;
    if ([cache isCachedForKey:_cacheKey]) {
        // load cache
        NSURLResponse *response;
        NSData *data = [cache cacheDataForKey:_cacheKey url:self.request.URL response:&response];
        if (!data || !response) {
            [cache removeCacheIndexForKey:_cacheKey];
            
            shouldLoad = YES;
            
        }else {
            
            shouldLoad = NO;
            
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        }
    }
    
    if (shouldLoad) {
        NSMutableURLRequest *mReq = [self.request mutableCopy];
        [NSURLProtocol setProperty:@(YES) forKey:kProtocolKey inRequest:mReq];
        self.connection = [[NSURLConnection alloc] initWithRequest:mReq delegate:self startImmediately:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.mData = [NSMutableData new];
    self.internalResponse = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    if ([self.internalResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.internalResponse;
        NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];
        
        // the network framework may be change the name of header field to lowercase
        if (contentType == nil) contentType = [httpResponse allHeaderFields][@"content-type"];
        
        if (contentType != nil && [contentType length] > 0) {
            [[TestURLProtocolCache sharedCache] storeCacheData:self.mData
                                                      response:self.internalResponse
                                                        forKey:_cacheKey
                                               completionBlock:nil];
        }
    }

}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
    self.mData = nil;
    self.internalResponse = nil;
}

@end
