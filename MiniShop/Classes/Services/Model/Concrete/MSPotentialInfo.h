//
//  MSPotential.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"
#import "MSGoodsList.h"

@interface MSPotentialInfo : MSObject
@property (nonatomic,strong)NSMutableArray *kink_goods_info;
@property (nonatomic)int next_page;
@end

@interface MSPotentialShop : MSObject
@property (nonatomic) int64_t mid;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSMutableArray *goods_info;
@end
