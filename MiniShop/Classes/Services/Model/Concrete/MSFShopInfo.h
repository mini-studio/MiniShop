//
//  MSFShopInfo.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSFShopInfo : MSObject

@property (nonatomic,strong)NSString *mid;

@property (nonatomic) int64_t numId;
@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) NSString *type;

@property (nonatomic) int64_t shop_id;
@property (nonatomic ,strong) NSString *shop_title;

/**是否关注*/
@property (nonatomic) NSInteger like;
/**是否已经收录*/
@property (nonatomic) NSInteger cooperate;
/**关注人数*/
@property (nonatomic) NSInteger like_num;

/**商店title*/
@property (nonatomic ,strong) NSString *shop_src_title;
/**商店名称*/
@property (nonatomic,strong) NSString  *taobao_shop_name;
@property (nonatomic, strong) NSString *taobao_shop_id;
@property (nonatomic) int num;

- (NSString *)realTitle;
- (NSString *)aliasTitle;

@end
