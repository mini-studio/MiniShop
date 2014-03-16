//
//  MSNGoodsTableCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-18.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNGoodsTableCell : UITableViewCell
@property (nonatomic,strong)NSArray *items;
@property (nonatomic,assign)UIViewController *controller;

+ (CGFloat)heightForItems:(NSArray*)items width:(CGFloat)maxWidth;

- (void)clearMemory;
@end

@interface MSNGoodsHeaderTableCell : UITableViewCell
@property(nonatomic,strong)id headerUserInfo;
@end
