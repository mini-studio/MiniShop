//
//  MSNDetailToolBar.h
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNGoodsList.h"

@interface MSNDetailToolBar : UIView
@property (nonatomic,strong)UILabel *goodsNameLabel;
@property (nonatomic,strong)UILabel *goodsPriceLabel;
@property (nonatomic,strong)MiniUIButton *button;


- (void)setGoodsInfo:(MSNGoodsItem*)item;
@end
