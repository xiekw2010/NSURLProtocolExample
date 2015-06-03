//
//  TestURLProtocolCache.h
//  Networking
//
//  Created by xiekw on 15/5/15.
//  Copyright (c) 2015年 隐风. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestURLProtocolCache : NSURLProtocol

+ (TestURLProtocolCache *)sharedCache;

- (BOOL)isCachedForKey:(NSString *)key;

- (NSData *)cacheDataForKey:(NSString *)key url:(NSURL *)url response:(NSURLResponse **)response;

- (void)storeCacheData:(NSData *)data
              response:(NSURLResponse *)response
                forKey:(NSString *)key
       completionBlock:(void (^)(BOOL succeed))completionBlock;

- (void)removeCacheIndexForKey:(NSString *)key;

+ (NSString *)cacheKeyForURL:(NSURL *)url;

@end
