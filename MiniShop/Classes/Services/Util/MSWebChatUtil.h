//
//  MSWebChatUtil.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSNGoodsItem;

@interface MSWebChatUtil : NSObject
+ (void)shareGoodsItem:(MSNGoodsItem*)GoodsItem scene:(int)scene;
+ (void)shareShop:(MSShopInfo*)shopInfo scene:(int)scene;
+ (void)shareShopList:(NSArray*)shopList scene:(int)scene;
@end
