//
//  MSWebChatUtil.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSWebChatUtil.h"
#import "WXApi.h"
#import "MSGoodsList.h"
#import "MSShopInfo.h"

@implementation MSWebChatUtil
#define BUFFER_SIZE 1024 * 100

+ (void)shareGoodItem:(MSGoodItem*)goodItem scene:(int)scene
{
    if(![WXApi isWXAppInstalled])
    {
        return;
    }
    if(![WXApi isWXAppSupportApi])
    {
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"分享个宝贝给你";
    message.description = goodItem.name;
    [message setThumbImage:goodItem.image];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"";
    ext.url = [NSString stringWithFormat:@"youjiaxiaodian://good/%lld",goodItem.mid];
    ext.fileData = nil;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;//WXSceneTimeline;
    [WXApi sendReq:req];
}

+ (void)shareShop:(NSString *)shopIds title:(NSString *)title description:(NSString *)description scene:(int)scene
{
    if(![WXApi isWXAppInstalled])
    {
        return;
    }
    if(![WXApi isWXAppSupportApi])
    {
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    
    
    NSString *url = [NSString stringWithFormat:@"http://youjiaxiaodian.com/share?type=share_shop&id=%@",shopIds];
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"";
    ext.url = url;
    ext.fileData = nil;
    message.mediaObject = ext;
    [message setThumbImage:[UIImage imageNamed:@"Icon.jpg"]];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;//WXSceneTimeline;
    [WXApi sendReq:req];
}

+ (void)shareShop:(MSShopInfo*)shopInfo scene:(int)scene
{
    [MobClick event:MOB_SHARE_SHOP];
    if ( scene == WXSceneTimeline )
    {
        NSString *desc = [NSString stringWithFormat:@"这家网店不错：%@",[shopInfo realTitle]];
        [self shareShop:[NSString stringWithFormat:@"%lld",shopInfo.shop_id] title:desc description:desc scene:scene];
    }
    else
    {
        NSString *desc = [NSString stringWithFormat:@"%@\n我觉得不错，你也看看",[shopInfo realTitle]];
        [self shareShop:[NSString stringWithFormat:@"%lld",shopInfo.shop_id] title:@"分享个网店给你" description:desc scene:scene];
    }
}

+ (void)shareShopList:(NSArray*)shopList scene:(int)scene
{
    [MobClick event:MOB_SHARE_SHOP_LIST];
    if ( shopList.count == 0 )
        return;
    NSMutableString *ids = [NSMutableString string];
    NSMutableString *desc = [NSMutableString stringWithFormat:@"一共%d家",[shopList count]];
    for ( MSShopInfo *shop  in shopList )
    {
        [ids appendFormat:@"%lld,",shop.shop_id];
        [desc appendFormat:@"，%@",shop.realTitle];
    }
    if ( ids.length > 0 )
    {
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1, 1)];
        if(scene==WXSceneTimeline)
        {
            NSString *title = [NSString stringWithFormat:@"分享：我喜欢的几家网店，%@",desc];
            [self shareShop:ids title:title description:title scene:scene];
        }
        else
        {
            [self shareShop:ids title:@"分享：我喜欢的几家网店" description:desc scene:scene];
        }
    }
    else
    {
        return;
    }
}

@end
