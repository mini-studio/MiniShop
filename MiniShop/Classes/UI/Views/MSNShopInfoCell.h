//
//  MSNShopInfoCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNShop.h"

@interface MSNShopInfoCell : UITableViewCell
@property (nonatomic,strong) MSNShopInfo* shopInfo;
@property (nonatomic,strong) MiniUIButton *button;
@property (nonatomic,strong) MiniUIButton *shareButton;
@property (nonatomic) BOOL showsShareButton;
+ (CGFloat)height:(MSNShopInfo *)shopInfo;
+ (void)resetButtonState:(MiniUIButton *)button shopInfo:(MSNShopInfo*)shopInfo;
@end
