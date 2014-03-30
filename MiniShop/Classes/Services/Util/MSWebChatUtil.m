//
//  MSWebChatUtil.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSWebChatUtil.h"
#import "WXApi.h"
#import "MSFShopInfo.h"
#import "MSNGoodsList.h"
#import "MSNShop.h"
#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"
#import "UMSocial.h"
#import "MSDefine.h"
#import <TencentOpenAPI/QQApiInterface.h>       //手机QQ SDK
#import <TencentOpenAPI/TencentOAuth.h>

#import "UMSocialWechatHandler.h"
#import "NSString+mini.h"

#define SNSNAMES @[UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToTencent,UMShareToQQ,UMShareToRenren,UMShareToDouban]

@implementation MSWebChatUtil
#define BUFFER_SIZE 10


+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem controller:(UIViewController *)controller
{
    
    NSString *url = @"haodianhui://goods";
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
    [UMSocialData defaultData].extConfig.title = @"分享个宝贝给你";
    UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
    
    wechatSessionData.url = url;
    NSString *info = [GoodsItem jsonString];
    wechatSessionData.extInfo = info;
        
    NSString *text = GoodsItem.shop_title;
    if (text==nil)text = @"";
    [UMSocialSnsService presentSnsIconSheetView:controller
                                         appKey:UM_KEY
                                      shareText:text
                                     shareImage:GoodsItem.image==nil?[UIImage imageNamed:@"icon.png"]:GoodsItem.image
                                shareToSnsNames:SNSNAMES
                                       delegate:nil];
}

+ (void)shareShop:(MSNShopInfo*)shopInfo controller:(UIViewController *)controller
{
    [MobClick event:MOB_SHARE_SHOP];
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    NSString *url = @"haodianhui://share_shop";

    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
    [UMSocialData defaultData].extConfig.title = @"这家网店不错";
    UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
    
    wechatSessionData.url = url;
    wechatSessionData.fileData = data;
    wechatSessionData.extInfo = shopInfo.shop_id;
    
    NSString *text = [shopInfo shop_title];
    if (text==nil)text = @"";
    
    [UMSocialSnsService presentSnsIconSheetView:controller
                                         appKey:UM_KEY
                                      shareText:text
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:SNSNAMES
                                       delegate:nil];
}

+ (void)shareShopList:(NSArray*)shopList controller:(UIViewController *)controller
{
    [MobClick event:MOB_SHARE_SHOP_LIST];
    if ( shopList.count == 0 )
        return;
    NSMutableString *ids = [NSMutableString string];
    NSMutableString *desc = [NSMutableString stringWithFormat:@"一共%d家",[shopList count]];
    for ( MSNShopInfo *shop  in shopList )
    {
        [ids appendFormat:@"%@,",shop.shop_id];
        [desc appendFormat:@"，%@",shop.shop_title];
    }
    if ( ids.length > 0 )
    {
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1, 1)];
        
        Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
        memset(pBuffer, 0, BUFFER_SIZE);
        NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
        free(pBuffer);

        NSString *url = @"haodianhui://share_shop";
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
        [UMSocialData defaultData].extConfig.title = @"分享：我喜欢的几家网店";
        UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
        
        wechatSessionData.url = url;
        wechatSessionData.fileData = data;
        wechatSessionData.extInfo = ids;
        
        [UMSocialSnsService presentSnsIconSheetView:controller
                                             appKey:UM_KEY
                                          shareText:desc
                                         shareImage:[UIImage imageNamed:@"icon.png"]
                                    shareToSnsNames:SNSNAMES
                                           delegate:nil];

    }
}

@end
