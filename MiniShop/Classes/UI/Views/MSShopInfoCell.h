//
//  MSShopInfoCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSShopInfo.h"

@interface MSShopInfoCell : UITableViewCell
@property (nonatomic,strong) MSShopInfo* shopInfo;
@property (nonatomic,strong) MiniUIButton *button;
@property (nonatomic,strong) MiniUIButton *shareButton;
@property (nonatomic) BOOL showsShareButton;
+ (CGFloat)height:(MSShopInfo *)shopInfo;
+ (void)resetButtonState:(MiniUIButton *)button shopInfo:(MSShopInfo*)shopInfo;
@end
