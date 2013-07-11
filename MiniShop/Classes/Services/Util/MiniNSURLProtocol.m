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
    if ( request != nil )
    {
        NSString *url = [[request URL] absoluteString];
        if ( [url rangeOfString:@"pds=addcart"].length > 0 ||
            [url rangeOfString:@"pds=buynow"].length > 0 ||
            [url rangeOfString:@"/ajax/order_ajax.do"].length > 0 )
        {
            NSString *postBody = @"";
            NSData * data = [request HTTPBody];
            if ( data != nil ) {
                postBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            NSString *param = [NSString stringWithFormat:@"%@&%@",url,postBody];
            [[ClientAgent sharedInstance] countorder:param block:nil];
        }        
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end
