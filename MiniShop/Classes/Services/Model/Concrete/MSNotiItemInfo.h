//
//  MSNotiItemInfo.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"
#import "MSShopInfo.h"

#define MSStoreNewsTypeStorePromotion   @"activity_shop"          // 店铺活动
#define MSStoreNewsTypeGoodsPromotion   @"activity_goods"       // 商品活动
#define MSStoreNewsTypeSaunter          @"look"                 // 随便看看
#define MSStoreNewsTypeNewProduct       @"online"              // 新品上架
#define MSStoreNewsTypePrevue           @"future"                // 新品剧透
#define MSStoreNewsTypeOffical          @"show"             // 官方推荐
#define MSStoreNewsTypeTopic            @"eyJ0eXBlIjoiYWxsX3RpbWUifQ=="
#define MSStoreNewsTypeURL              @"url"
#define MSStoreNewsSubTypeReg           @"reg"
#define MSStoreNewsSubTypeSubLogin      @"login"


@interface MSNotiItemInfo : MSObject
@property (nonatomic) int64_t  mid;
@property (nonatomic) int64_t  items_id;
@property (nonatomic) NSString *iId;
@property (nonatomic, strong) NSString * name;
// look: eyJ0eXBlIjoiYWxsX3RpbWUifQ== 随便看看  activity_shop:店铺活动 activity_goods:商品活动 online:上新 future:剧透
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *subtype;
@property (nonatomic, strong) NSString *look_type;
@property (nonatomic, strong) NSString *shop_title;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *start_time;
@property (nonatomic, strong) NSString *end_time;
@property (nonatomic, strong) id intro;
@property (nonatomic, strong) NSString *publish_time;
@property (nonatomic)         NSInteger shop_id;

@property (nonatomic)         int64_t   numId;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *small_image_url;
@property (nonatomic)CGSize small_image_size_;
@property (nonatomic, strong) NSString *big_image_url;
@property (nonatomic)CGSize big_image_size_;
@property (nonatomic, strong) NSString *rush_buy;
@property (nonatomic, strong) NSString *sku_num;
@property (nonatomic, strong) NSString *activity;

@property (nonatomic, strong) NSArray *goods_ids;
@property (nonatomic, strong) NSArray *goods_names;
@property (nonatomic) NSInteger goods_num;

@property (nonatomic)BOOL isNews;

- (NSString *)typeNoteDesc;
- (UIColor *)typeNoteColor;
- (NSString *)typeTitleDesc;
- (NSString *)realName;
- (id)realIntro;

- (void)setRead:(BOOL)read;
- (BOOL)read;

@end

@interface MSPicNotiGroupItemInfo : MSObject
@property (nonatomic,strong) MSShopInfo *shop_info;
@property (nonatomic,strong) NSArray    *goods_info;
@end

@interface MSNotiGroupInfo : MSNotiItemInfo
@property (nonatomic,strong) MSShopInfo *shop_info;
@property (nonatomic,strong) NSArray    *items_info;
@end

@interface MSPicNotiGroupInfo : MSNotiItemInfo
@property (nonatomic,strong) MSPicNotiGroupItemInfo *items_info;
- (int64_t)mid;
@end


