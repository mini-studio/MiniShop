//
//  MSNShop.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSNShopInfo : MSObject
@property(nonatomic,strong)NSString *seller_nick;
@property(nonatomic,strong)NSString *shop_address;
@property(nonatomic,strong)NSString *shop_goods_num;
@property(nonatomic,strong)NSString *shop_grade;
@property(nonatomic,strong)NSString *shop_id;
@property(nonatomic,strong)NSString *shop_like_num;
@property(nonatomic,strong)NSString *shop_title;
@property(nonatomic,strong)NSString *shop_type;
@property(nonatomic)int like;
@end


@interface MSNShopList : MSObject
@property (nonatomic,strong) NSArray *info;

- (void)append:(MSNShopList*)list;
@end
