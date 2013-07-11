//
//  MSCooperateInfo.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface  MSCooperateGoodInfo : MSObject
@property (nonatomic,strong) NSString *tsrtcg_id;
@property (nonatomic,strong) NSString *taobao_shop_id;
@property (nonatomic,strong) NSString *tsrtcg_goods_image_url;
@end

@interface MSCooperateInfo : MSObject
@property (nonatomic,strong) NSString *taobao_shop_id;
@property (nonatomic,strong) NSString *taobao_shop_title;
@property (nonatomic,strong) NSString *seller_nick;
@property (nonatomic,strong) NSString *user;
@property (nonatomic,strong) NSArray  *goods_info;
@property (nonatomic) NSInteger limit;
@property (nonatomic,strong) NSString *msg;

@end

@interface MSCooperateData : MSObject
@property (nonatomic,strong) MSCooperateInfo *info;
@property (nonatomic) int  limit;
@property (nonatomic,strong) NSString *msg;
@end
