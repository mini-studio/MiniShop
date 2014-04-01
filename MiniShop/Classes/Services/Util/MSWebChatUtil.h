//
//  MSWebChatUtil.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocialControllerService.h"
@class MSNGoodsItem;
@class MSNShopInfo;

@interface MSWebChatUtil : NSObject
@property (nonatomic,strong) id userInfo;
+ (MSWebChatUtil*)instance;
+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem controller:(UIViewController *)controller;
+ (void)shareShop:(MSNShopInfo*)shopInfo controller:(UIViewController *)controller;
+ (void)shareShopList:(NSArray*)shopList controller:(UIViewController *)controller;
@end


@interface MSNUMSocialUIMonitor : NSObject<UMSocialUIDelegate>
@property (nonatomic,strong) void (^callback)(NSString *platformName,UMSocialData *socialData);
@end