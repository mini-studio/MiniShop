//
//  ;
//  MiniShop
//
//  Created by Wuquancheng on 13-12-15.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

#define SORT_TIME @"time"
#define SORT_SALE @"sale"
#define SORT_DISCOUNT @"off"
#define SORT_OFF_TIME @"off_time"

@interface MSNFavshopList : MSObject
@property (nonatomic)int goods_num;
@property (nonatomic,strong)NSArray *info;
@property (nonatomic)int shop_num;
@property (nonatomic,strong)NSString *sort;

- (void)append:(MSNFavshopList*)list;
- (void)group;

- (NSArray *)dataAtIndex:(unsigned)index;
- (int)numberOfRows;
@end

@interface MSNGoodItem : MSObject
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

@property (nonatomic,strong)NSString *goods_date;
@end
