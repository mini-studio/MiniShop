//
//  MSNDetailToolBar.h
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNGoodsList.h"

@interface MSNDetailToolFeatureView : UIView
@property (nonatomic,strong)MiniUIButton *buyButton;
@property (nonatomic,strong)MiniUIButton *favButton;
@property (nonatomic,strong)MiniUIButton *shareButton;
@end

@interface MSNDetailToolBar : UIView
@property (nonatomic,strong)UILabel *goodsNameLabel;
@property (nonatomic,strong)UILabel *goodsPriceLabel;
@property (nonatomic,strong)MiniUIButton *buybutton;


- (void)setGoodsInfo:(MSNGoodsItem*)item;

@end
