//
//  MSShopInfo.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSShopInfo : MSObject
@property (nonatomic) bool ZM;
@property (nonatomic) bool ZY;
@property (nonatomic) bool c;
@property (nonatomic) int collectCount;
@property (nonatomic ,strong) NSString *collecttime;
@property (nonatomic ,strong) NSString *img;
@property (nonatomic) bool mall;
@property (nonatomic) int newGoddsCount;
@property (nonatomic) int64_t numId;
@property (nonatomic) int64_t ownerId;
@property (nonatomic ,strong) NSString *ownernick;
@property (nonatomic ,strong) NSString *rank;
@property (nonatomic ,strong) NSString *tag;
@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) NSString *type;

@property (nonatomic) int64_t shop_id;
@property (nonatomic ,strong) NSString *shop_title;
@property (nonatomic ,strong) NSString *shop_sid;

@property (nonatomic) NSInteger like;
@property (nonatomic) NSInteger cooperate;
@property (nonatomic) NSInteger like_num;

@property (nonatomic ,strong) NSString *shop_src_title;
@property (nonatomic ,strong) NSString *tags;
@property (nonatomic ,strong) NSString *recommend;

@property (nonatomic,strong) NSString *taobao_shop_id;
@property (nonatomic,strong) NSString *taobao_shop_name;
@property (nonatomic,strong) NSString *taobao_user_nick;
@property (nonatomic,strong) NSString *taobao_shop_tag;
@property (nonatomic,strong) NSString *taobao_shop_pic;
@property (nonatomic,strong) NSString *taobao_shop_level_image;
@property (nonatomic,strong) NSString *taobao_shop_type;
@property (nonatomic,strong) NSString *taobao_domain;
@property (nonatomic,strong) NSString *taobao_shop_mobile_url;
@property (nonatomic,strong) NSString *taobao_shop_web_url;
@property (nonatomic) int num;



- (NSString *)realTitle;
- (NSString *)aliasTitle;

@end
