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
+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem scene:(int)scene;
+ (void)shareShop:(MSNShopInfo*)shopInfo scene:(int)scene;
+ (void)shareShopList:(NSArray*)shopList scene:(int)scene;
@end
