//
//  MSShopInfo.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopInfo.h"

@implementation MSShopInfo

- (NSString *)realTitle
{
    if ( self.shop_id == 0 )
    {
        if ( self.taobao_shop_name.length > 0 )
        {
            return self.taobao_shop_name;
        }
    }
    if ( self.shop_title.length > 0 )
    {
        return self.shop_title;
    }
    return self.title;
}

- (NSString *)aliasTitle
{
    if ( self.shop_id == 0 )
    {
        return self.taobao_shop_name;
    }
    if ( self.shop_src_title.length > 0 )
    {
        return self.shop_src_title;
    }
    else
    {
        return nil;
    }
}

- (void)setTaobao_shop_id:(NSString *)taobao_shop_id
{
    _taobao_shop_id = taobao_shop_id;
    self.numId = [taobao_shop_id longLongValue];
}

- (void)setTaobao_shop_name:(NSString *)taobao_shop_name
{
    _taobao_shop_name = taobao_shop_name;
    self.title = taobao_shop_name;
}
@end
