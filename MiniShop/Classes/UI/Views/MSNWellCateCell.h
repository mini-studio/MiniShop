//
//  MSNWellCateCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNCate.h"

@protocol MSNWellCateCellDelegate <NSObject>
@required
- (void)handleTouchInfo:(MSNWellCate *)cate;
@end

@interface MSNWellCateCell : UITableViewCell
@property(nonatomic,strong)MSNWellCateGroup *group;
@property(nonatomic,assign)id<MSNWellCateCellDelegate> wellCateCellDelegate;
+ (CGFloat)heightForGroup:(MSNWellCateGroup*)group;
@end
