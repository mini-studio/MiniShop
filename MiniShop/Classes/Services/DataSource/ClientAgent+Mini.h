//
//  ClientAgent+LS.h
//  xcmg
//
//  Created by Wuquancheng on 12-11-11.
//  Copyright (c) 2012年 mini. All rights reserved.
//

#import "ClientAgent.h"

#define StoreGoUrl              @"youjiaxiaodian.com/h12"

@class MSShopInfo;

@interface ClientAgent (LS)

+ (NSString *)host;

+ (NSString *)imageUrl:(NSString *)path;

+ (NSString *)jumpToTaoBaoUrl:(NSString *)type;

+ (NSString *)prefectUrl:(NSString*)url;
- (void)perfectHttpRequest:(NSMutableURLRequest *)requst;

- (void)registe:(NSString*)uname passwd:(NSString*)passwd mobile:(NSString*)mobile block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)login:(NSString*)uname passwd:(NSString*)passwd  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)resetpasswd:(NSString*)uname mobile:(NSString*)mobile  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)feedback:(NSString *)content block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;


- (void)version:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)auth:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)uploadToken:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;


- (void)importFav:(MiniViewController *)controller userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)shopsInfo:(NSArray *)taobaolist userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

//订单详情页上传
- (void)loadOrderDetail:(NSString *)url userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
- (void)countlist:(NSData *)url  userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

//用户放大了图片
- (void)viewsec:(int64_t)goodId  from:(NSString *)from sec:(int)sec block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
- (void)countorder:(NSString*)params block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;



@end


@interface ClientAgent (LS14)
//我的商城分类
- (void)favshopcate:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//我的商城列表
- (void)favshoplist:(NSString*)tagId sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//特卖汇分类
- (void)specialcate:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//特卖汇列表
- (void)specialgoods:(NSString*)type page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//好店汇分类
- (void)catelist:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//搜索店铺 key=a&sort=&page=1&tag_id=
- (void)searchshop:(NSString*)key sort:(NSString*)sort page:(int)page tag_id:(int)tag_id block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
- (void)searchgoods:(NSString*)key type:(NSString*)type sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//收藏店铺
- (void)setfavshop:(NSString*)shopId action:(NSString*)action block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
- (void)myshoplist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
//收藏商品
- (void)setfavgoods:(NSString*)mid action:(NSString*)action block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
- (void)mygoodslist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
//商品详情
- (void)goodsinfo:(NSString*)goodId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
//店铺内商品
- (void)shopgoods:(NSString*)shopId tagId:(NSString*)tagId sort:(NSString*)sort key:(NSString*)key page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;
//店铺内标签
- (void)shoptag:(NSString*)shopId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
//猜你喜欢
- (void)guesslikeshop:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;;

- (void)setpushsound:(int)action block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

- (void)getpushsound:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block;

@end

