//
//  MSWebChatUtil.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSNGoodsItem;
@class MSNShopInfo;

@interface MSWebChatUtil : NSObject
+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem controller:(UIViewController *)controller;
+ (void)shareShop:(MSNShopInfo*)shopInfo controller:(UIViewController *)controller;
+ (void)shareShopList:(NSArray*)shopList controller:(UIViewController *)controller;
@end
