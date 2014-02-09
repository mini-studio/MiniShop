//
//  MSNDetailToolBar.h
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNGoodsList.h"
#import "MSNShopInfoView.h"

@interface MSNDetailToolBar : UIView
@property (nonatomic,strong)UILabel *goodsNameLabel;
@property (nonatomic,strong)UILabel *goodsPriceLabel;
@property (nonatomic,strong)MiniUIButton *buybutton;
@property (nonatomic,strong)MSNShopInfoView* shopInfoView;

- (void)setGoodsInfo:(MSNGoodsItem*)item;

@end