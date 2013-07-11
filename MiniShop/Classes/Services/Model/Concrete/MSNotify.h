//
//  MSNotify.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSNotify : MSObject
@property (nonatomic,strong) NSString *welcome;
@property (nonatomic,strong) NSArray *items_info;
@property (nonatomic,strong) NSArray *official;
@property (nonatomic,strong) NSArray *topic;
@property (nonatomic)NSInteger future_maxid;
@property (nonatomic)NSInteger online_maxid;
@end
