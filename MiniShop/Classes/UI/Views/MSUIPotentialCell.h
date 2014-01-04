//
//  MSPotentialCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPotentialInfo.h"

@interface MSUIPotentialCell : UITableViewCell

@property (nonatomic,strong)NSMutableArray *dataSource;

@property (nonatomic,strong) void (^handleTouchItem)(MSGoodsItem *item);

+ (CGFloat)heightForShopInfo:(NSMutableArray*)array;
@end
