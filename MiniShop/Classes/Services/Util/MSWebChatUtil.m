//
//  MSWebChatUtil.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSWebChatUtil.h"
#import "WXApi.h"
#import "MSShopInfo.h"
#import "MSNGoodsList.h"
#import "MSNShop.h"


@implementation MSWebChatUtil
#define BUFFER_SIZE 10

+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem scene:(int)scene
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
    message.description = GoodsItem.goods_title;
    if (GoodsItem.image!=nil)
    [message setThumbImage:GoodsItem.image];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"";
    ext.url = [NSString stringWithFormat:@"youjiaxiaodian://good/%lld",GoodsItem.mid];
    
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);

    ext.fileData = data;
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
    ext.extInfo = shopIds;
    ext.url = url;
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    ext.fileData = data;
    message.mediaObject = ext;
    [message setThumbImage:[UIImage imageNamed:@"Icon.jpg"]];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;//WXSceneTimeline;
    [WXApi sendReq:req];
}

+ (void)shareShop:(MSNShopInfo*)shopInfo scene:(int)scene
{
    [MobClick event:MOB_SHARE_SHOP];
    if ( scene == WXSceneTimeline )
    {
        NSString *desc = [NSString stringWithFormat:@"这家网店不错：%@",[shopInfo shop_title]];
        [self shareShop:[NSString stringWithFormat:@"%@",shopInfo.shop_id] title:desc description:desc scene:scene];
    }
    else
    {
        NSString *desc = [NSString stringWithFormat:@"%@\n我觉得不错，你也看看",[shopInfo shop_title]];
        [self shareShop:[NSString stringWithFormat:@"%@",shopInfo.shop_id] title:@"分享个网店给你" description:desc scene:scene];
    }
}

+ (void)shareShopList:(NSArray*)shopList scene:(int)scene
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
