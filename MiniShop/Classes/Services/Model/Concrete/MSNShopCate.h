//
//  MSShopCate.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-11.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSNShopCate : MSObject
@property (nonatomic,strong) NSString *tag_id;
@property (nonatomic,strong) NSString *tag_name;
@end

@interface MSNShopCateInfo : MSObject
@property (nonatomic,strong)NSArray *info;
@end
