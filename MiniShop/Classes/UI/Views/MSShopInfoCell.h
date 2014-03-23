//
//  MSShopInfoCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSFShopInfo.h"

@interface MSShopInfoCell : UITableViewCell
@property (nonatomic,strong) MSFShopInfo * shopInfo;
@property (nonatomic,strong) MiniUIButton *button;
+ (CGFloat)height:(MSFShopInfo *)shopInfo;
+ (void)resetButtonState:(MiniUIButton *)button shopInfo:(MSFShopInfo *)shopInfo;
@end
