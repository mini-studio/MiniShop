//
//  MSRecmdList.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSRecmdList.h"
#import "MSShopInfo.h"
#import "MSGoodsList.h"
#import "MSSearchKeyInfo.h"

@implementation MSRecmdList
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"recommend_shop_info" isEqualToString:attriName] )
    {
        return [MSShopInfo class];
    }
    else if ( [@"word_info" isEqualToString:attriName] )
    {
        return [MSSearchKeyInfo class];
    }
    return nil;
}
@end

@implementation MSFollowedList
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"like_shop_info" isEqualToString:attriName] )
    {
        return [MSShopInfo class];
    }
    return nil;
}
@end


@implementation MSSearchList
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"search_shop_info" isEqualToString:attriName] || [@"taobao_search_shop_info" isEqualToString:attriName] || [@"shop_info" isEqualToString:attriName] )
    {
        return [MSShopInfo class];
    }
    return nil;
}
- (NSArray *)search_shop_info
{
    if ( _search_shop_info == nil ) {
        _search_shop_info = _shop_info;
    }
    return _search_shop_info;
}
@end