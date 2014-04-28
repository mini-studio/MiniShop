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

MSWebChatUtil *shareUtil = nil;

+ (MSWebChatUtil*)instance
{
    if (shareUtil==nil) {
        shareUtil = [[MSWebChatUtil alloc] init];
    }
    return shareUtil;
}

+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem controller:(UIViewController *)controller
{
    NSString *info = [GoodsItem jsonString];
    NSString *url = [NSString stringWithFormat:@"%@/new/share?scheme=haodianhui&m=goods&id=%@",[ClientAgent host],GoodsItem.goods_id];
    
    NSString *text = GoodsItem.shop_title;
    if (text==nil)text = @"";
    
    MSNUMSocialUIMonitor *monitor = [[MSNUMSocialUIMonitor alloc] init];
    monitor.callback = ^(NSString *platformName,UMSocialData *socialData) {
        if ([UMShareToQQ isEqualToString:platformName]) {
            [UMSocialData defaultData].extConfig.qqData.webUrl = url;
            [UMSocialData defaultData].extConfig.qqData.title = @"分享个宝贝给你";
        }
        else if ([UMShareToWechatSession isEqualToString:platformName] || [UMShareToWechatTimeline isEqualToString:platformName]) {
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
            if ([UMShareToWechatTimeline isEqualToString:platformName]) {
               [UMSocialData defaultData].extConfig.title = @"分享个宝贝";
            }
            else {
                [UMSocialData defaultData].extConfig.title = @"分享个宝贝给你";
            }
            UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
            wechatSessionData.url = url;
            wechatSessionData.extInfo = info;
        }
        else {
            socialData.shareText = [NSString stringWithFormat:@"分享个宝贝:%@%@",text,url];
        }
    };
    [MSWebChatUtil instance].userInfo = monitor;
    
    [UMSocialSnsService presentSnsIconSheetView:controller
                                         appKey:UM_KEY
                                      shareText:text
                                     shareImage:(GoodsItem.image==nil?[UIImage imageNamed:@"newpic"]:GoodsItem.image)
                                shareToSnsNames:SNSNAMES
                                       delegate:monitor];
}

+ (void)shareShop:(MSNShopInfo*)shopInfo controller:(UIViewController *)controller
{
    [MobClick event:MOB_SHARE_SHOP];
    NSString *url = [NSString stringWithFormat:@"%@/new/share?scheme=haodianhui&m=share_shop&ids=%@",[ClientAgent host],shopInfo.shop_id];
    NSString *text = [shopInfo shop_title];
    if (text==nil)text = @"";
    MSNUMSocialUIMonitor *monitor = [[MSNUMSocialUIMonitor alloc] init];
    monitor.callback = ^(NSString *platformName,UMSocialData *socialData) {
        if ([UMShareToQQ isEqualToString:platformName]) {
            [UMSocialData defaultData].extConfig.qqData.webUrl = url;
            [UMSocialData defaultData].extConfig.qqData.title = @"这家网店不错";
        }
        else if ([UMShareToWechatSession isEqualToString:platformName] || [UMShareToWechatTimeline isEqualToString:platformName]) {
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
            [UMSocialData defaultData].extConfig.title = @"这家网店不错";
            UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
            
            wechatSessionData.url = url;
            wechatSessionData.extInfo = shopInfo.shop_id;
        }
        else {
            socialData.shareText = [NSString stringWithFormat:@"这家网店不错:%@%@",text,url];
        }
    };
    [MSWebChatUtil instance].userInfo = monitor;

    
    [UMSocialSnsService presentSnsIconSheetView:controller
                                         appKey:UM_KEY
                                      shareText:text
                                     shareImage:(shopInfo.logo==nil?[UIImage imageNamed:@"newpic"]:shopInfo.logo)
                                shareToSnsNames:SNSNAMES
                                       delegate:monitor];
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
        NSString *url = [NSString stringWithFormat:@"%@/new/share?scheme=haodianhui&m=share_shop&ids=%@",[ClientAgent host],ids];
        
        MSNUMSocialUIMonitor *monitor = [[MSNUMSocialUIMonitor alloc] init];
        monitor.callback = ^(NSString *platformName,UMSocialData *socialData) {
            NSString *text = desc;
            if (text.length>60) {
                text = [desc substringToIndex:60];
            }
            if ([UMShareToQQ isEqualToString:platformName]) {
                [UMSocialData defaultData].extConfig.qqData.webUrl = url;
                [UMSocialData defaultData].extConfig.qqData.title = @"分享：我喜欢的几家网店";
                NSString *text = desc;
                if (text.length>60) {
                    text = [desc substringToIndex:60];
                }
                socialData.shareText = [NSString stringWithFormat:@"分享：我喜欢的几家网店:%@%@",text,url];
            }
            else if ([UMShareToWechatSession isEqualToString:platformName] || [UMShareToWechatTimeline isEqualToString:platformName]) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
                [UMSocialData defaultData].extConfig.title = @"分享：我喜欢的几家网店";
                UMSocialWechatSessionData *wechatSessionData = [UMSocialData defaultData].extConfig.wechatSessionData;
                
                wechatSessionData.url = url;
                wechatSessionData.extInfo = ids;
                
                socialData.shareText = text;
            }
            else {
                socialData.shareText = [NSString stringWithFormat:@"分享：我喜欢的几家网店:%@ %@",text,url];
            }
        };
        [MSWebChatUtil instance].userInfo = monitor;

        
        
        
        [UMSocialSnsService presentSnsIconSheetView:controller
                                             appKey:UM_KEY
                                          shareText:@""
                                         shareImage:[UIImage imageNamed:@"newpic"]
                                    shareToSnsNames:SNSNAMES
                                           delegate:monitor];

    }
}

@end

@implementation MSNUMSocialUIMonitor

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if (self.callback!=nil) {
        self.callback(platformName,socialData);
    }
}

@end
