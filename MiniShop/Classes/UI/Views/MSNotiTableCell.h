//
//  MSNotiTableCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNotiItemInfo.h"

@interface MSNotiTableCell : UITableViewCell
@property (nonatomic,strong)MSNotiItemInfo *item;

+ (CGFloat)heightForItem:(MSNotiItemInfo *)item width:(CGFloat)maxWidth;

@end
