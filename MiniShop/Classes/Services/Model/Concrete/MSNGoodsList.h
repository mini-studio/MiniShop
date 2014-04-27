//
//  ;
//  MiniShop
//
//  Created by Wuquancheng on 13-12-15.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"
#import "MSNShop.h"

#define SORT_TIME @"time"
#define SORT_SALE @"sale"
#define SORT_DISCOUNT @"off"
#define SORT_OFF_TIME @"off_time"

@class MSNGoodsDetail;

@interface MSNGoodsList : MSObject
@property (nonatomic)int goods_num;
@property (nonatomic,strong)NSArray *info;
@property (nonatomic)int shop_num;
@property (nonatomic, strong)NSString *search_shop_null_message;
@property (nonatomic,strong)NSString *sort;

- (void)append:(MSNGoodsList*)list;
- (void)group;

- (NSArray *)dataAtIndex:(unsigned)index;
- (NSString *)keyAtIndex:(unsigned)index;
- (int)numberOfRows;

- (NSArray *)allSortedItems;
@end

@interface MSNGoodsItem : MSObject
@property (nonatomic)int64_t mid;
@property (nonatomic,strong)NSString *big_image_url;
@property (nonatomic,strong)NSString *goods_create_time;
@property (nonatomic,strong)NSString *goods_id;
@property (nonatomic,strong)NSString *goods_marked_price;
@property (nonatomic,strong)NSString *goods_sale_price;
@property (nonatomic,strong)NSString *goods_title;
@property (nonatomic,strong)NSString *image_url;
@property (nonatomic,strong)NSString *micro_image_url;
@property (nonatomic,strong)NSString *middle_image_url;
@property (nonatomic,strong)NSString *small_image_url;
@property (nonatomic,strong)NSString *price_history_intro;
@property (nonatomic,strong)NSString *goods_sales_intro;
@property (nonatomic,strong)NSString *shop_id;
@property (nonatomic,strong)NSString *shop_title;
@property (nonatomic,strong)NSString *goods_url;
@property (nonatomic,strong)NSString *goods_sale_num;
@property (nonatomic)int like_goods;
@property (nonatomic,strong)NSString *shop_grade;

@property (nonatomic,strong)NSString *goods_date;
@property (nonatomic,strong)MSNGoodsDetail *detail;
@property (nonatomic,strong)NSString *economizer;
@property (nonatomic,strong)NSString *discount;
@property (nonatomic,strong)UIImage *image;

@property (nonatomic)int imageSizeType;
@property (nonatomic)CGSize imageSize;

- (void)copy:(MSNGoodsItem *)other;

@end

@interface MSNGoodsDetailInfo : MSObject
@property (nonatomic,strong)MSNGoodsItem *goods_info;
@property (nonatomic,strong)NSArray *collocation_info;
@end
@interface MSNGoodsDetail : MSObject
@property (nonatomic,strong) MSNShopInfo *shop_info;
@property (nonatomic,strong) MSNGoodsDetailInfo *info;
@end
