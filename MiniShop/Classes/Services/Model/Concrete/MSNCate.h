//
//  MSShopCate.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-11.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"
//我的商城分类
@interface MSNCate : MSObject
@property (nonatomic,strong) NSString *tag_id;
@property (nonatomic,strong) NSString *tag_name;
@end
//我的商城分类列表
@interface MSNCateList : MSObject
@property (nonatomic,strong)NSArray *info;
@end

//特卖汇分类
@interface MSNSpecialcate : MSObject
@property (nonatomic,strong) NSString *mid;
@property (nonatomic,strong) NSString *name;
@end

//好店汇分类
@interface MSNWellCate : MSObject
@property (nonatomic,strong) NSString *image_url;
@property (nonatomic) NSInteger param;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *type;
@end

//好店汇分类
@interface MSNWellCateGroup : MSObject
@property (nonatomic,strong) NSArray *item;
@property (nonatomic,strong) NSString *title;
@end

@interface MSNWellCateList : MSObject
@property (nonatomic,strong) NSArray *info;
@end;