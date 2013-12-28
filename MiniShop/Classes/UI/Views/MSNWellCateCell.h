//
//  MSNWellCateCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNCate.h"

@interface MSNWellCateCell : UITableViewCell
@property(nonatomic,strong)MSNWellCateGroup *group;
+ (CGFloat)heightForGroup:(MSNWellCateGroup*)group;
@end
