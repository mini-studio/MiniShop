//
//  MiniNSURLProtocol.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-15.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniNSURLProtocol.h"
#import "NSString+Mini.h"

@implementation MiniNSURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
//    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.168 Safari/535.19";
//	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userAgent, @"UserAgent", nil];
//	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    if ( request != nil ) {
        NSString *url = [[request URL] absoluteString];
        LOG_DEBUG(@"%@",url);
        if ( [url rangeOfString:@"api=mtop.trade.addBag"].length > 0 ||
            [url rangeOfString:@"api=mtop.trade.buildOrder.ex"].length > 0 ||
            [url rangeOfString:@"api=mtop.trade.createOrder.ex"].length > 0 ) {
            NSString *postBody = @"";
            NSData * data = [request HTTPBody];
            if ( data != nil ) {
                postBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            NSString *param = [NSString stringWithFormat:@"%@&%@",url,postBody];
            [[ClientAgent sharedInstance] countOrder:param block:nil];
        }
        if ([url rangeOfString:@"mtop.trade.addBag"].length > 0) {
            [MobClick event:MOB_TAOBAO_ADD_BAG];
        }
        else if ([url rangeOfString:@"mtop.trade.buildOrder.ex"].length > 0) {
            [MobClick event:MOB_TAOBAO_BUY_NOW];
        }
        else if ([url rangeOfString:@"mtop.trade.createOrder.ex"].length >0) {
            [MobClick event:MOB_TAOBAO_CREATE_ORDER];
        }
        
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end
