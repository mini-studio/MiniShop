//
//  MSUser.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUser.h"

@implementation MSUser
- (void)setImei:(id)imei
{
    if ( [imei isKindOfClass:[NSNumber class]] ) {
        _imei = [NSString stringWithFormat:@"%lld",[(NSNumber*)imei longLongValue]];
    }
    else {
        _imei = imei;
    }
    if ( _imei.length > 0 ) {
        MSSystem *system = [MSSystem sharedInstance];
        system.udid = _imei;
    }
}

@end
