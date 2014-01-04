//
//  MSGoodsList.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"


@interface MSGoodsItem : MSObject
@property (nonatomic) int64_t mid;
@property (nonatomic) NSString *ogoods_id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *image_key;
@property (nonatomic,strong) NSString *image_url;
@property (nonatomic,strong) NSString *small_image_url;
@property (nonatomic,strong) NSString *big_image_url;
@property (nonatomic) NSInteger user_goods_image_num;
@property (nonatomic) NSInteger rush_buy;
@property (nonatomic) NSString* sku_num;
@property (nonatomic,strong) NSString *activity;
@property (nonatomic) NSInteger like;
@property (nonatomic,strong)NSString *shop_title;
@property (nonatomic,strong)NSString *price;

@property (nonatomic) int64_t taobao_goods_id;
@property (nonatomic,strong) NSString *goods_url;

@property (nonatomic,strong)UIImage *image;

@property (nonatomic,strong)NSString *shop_name;
@property (nonatomic)int64_t shop_id;
@property (nonatomic,strong)NSString *date;

- (void)setRead:(BOOL)read;

+ (BOOL)isRead:(int64_t)mid;
@end

@interface MSGoodsListInfo : MSObject
@property (nonatomic) int64_t  mid;
@property (nonatomic) NSInteger status;
@property (nonatomic) int64_t shop_id;
@property (nonatomic,strong) NSString * shop_name;
@property (nonatomic,strong) NSString * publish_time;
@property (nonatomic) NSInteger goods_num;
@end

@interface MSGoodsList : MSObject
@property (nonatomic) NSInteger user_is_like_shop;
@property (nonatomic) NSInteger shop_id;
@property (nonatomic) NSString  *shop_name;
@property (nonatomic,strong)NSArray *body_info;
@property (nonatomic,strong)MSGoodsListInfo *pre_info;
@property (nonatomic,strong)MSGoodsListInfo *next_info;
@property (nonatomic) NSInteger next_page;
@end

@interface MSShopGalleryItemInfo : MSGoodsItem
@property (nonatomic,strong) NSString *publish_time;
@property (nonatomic) NSInteger  goods_num;
@property (nonatomic,strong)NSString *shop_name;
@end

@interface MSShopGalleryInfo : MSObject
@property (nonatomic,strong) MSShopGalleryItemInfo *item_info;
@property (nonatomic,strong) NSArray *goods_info;
@end

@interface MSShopGalleryList : MSObject
@property (nonatomic) NSInteger user_is_like_shop;
@property (nonatomic,strong)NSArray *body_info;

- (void)appendGoodsItems:(NSArray *)items;
@end
