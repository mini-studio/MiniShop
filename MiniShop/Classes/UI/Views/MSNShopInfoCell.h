//
//  MSNShopInfoCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNShop.h"

@protocol MSNShopInfoCellDelegate <NSObject>
@required
- (void)favShop:(MSNShopInfo*)shopInfo;
- (void)cancelFavShop:(MSNShopInfo*)shopInfo;
@end

@interface MSNShopInfoCell : UITableViewCell
@property (nonatomic,assign) id<MSNShopInfoCellDelegate> shopInfoDelegate;
@property (nonatomic,strong) MSNShopInfo* shopInfo;
+ (CGFloat)height:(MSNShopInfo *)shopInfo;
@end
