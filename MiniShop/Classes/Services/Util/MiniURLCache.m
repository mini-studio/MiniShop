//
//  MiniURLCache.m
//  Buke
//
//  Created by Wuquancheng on 13-1-19.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniURLCache.h"
#import "NSString+Mini.h"
#import "NSData+Base64.h"

static MiniURLCache* cache = nil;

@implementation MiniURLCache

+ (MiniURLCache *)sharedCache
{
    if ( cache == nil )
    {
        cache = [[MiniURLCache alloc] init];
    }
    return cache;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"START_WEB_RQ" object:nil];
    return [super cachedResponseForRequest:request];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"END_WEB_RQ" object:nil];
    if ( [[[request URL] absoluteString] rangeOfString:@"mtop.order.queryOrderDetail"].length > 0 )
    {
        NSString *fpath = [ClientAgent filePathForKey:@"ms_count_queryOrderDetail"];
        [cachedResponse.data writeToFile:fpath atomically:YES];
        //[[ClientAgent sharedInstance] countlist:cachedResponse.data userInfo:nil block:nil];
    }
    [super storeCachedResponse:cachedResponse forRequest:request];
}

@end
