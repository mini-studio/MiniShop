//
//  MSRecmdList.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSRecmdList : MSObject
@property (nonatomic,strong)NSArray *recommend_shop_info;
@property (nonatomic,strong)NSArray *word_info;
@end

@interface MSFollowedList : MSObject
@property (nonatomic,strong)NSArray *like_shop_info;
@end


@interface MSSearchList : MSObject
@property (nonatomic,strong)NSArray *search_shop_info;
@property (nonatomic,strong)NSArray *shop_info;
@property (nonatomic,strong)NSArray *taobao_search_shop_info;
@property (nonatomic,strong)NSArray *search_shop_ids;
@end
