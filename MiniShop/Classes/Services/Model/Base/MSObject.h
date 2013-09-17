//
//  MSObject.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniObject.h"

@interface MSObject : MiniObject
@property (nonatomic) NSInteger _errno;
@property (nonatomic,strong) NSString *error;
@property (nonatomic,strong) NSString *show_msg;
@property (nonatomic) NSInteger next_page;
@end
