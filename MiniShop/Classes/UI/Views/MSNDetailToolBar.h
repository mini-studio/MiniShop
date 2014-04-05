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

@interface MSNRelatedGoodsView : UIView
@end;

@interface MSNDetailToolBar : UIView
@property (nonatomic, strong)UILabel *goodsNameLabel;
@property (nonatomic, strong)UILabel *goodsPriceLabel;
@property (nonatomic, strong)MiniUIButton *buyButton;
@property (nonatomic, strong)MSNShopInfoView* shopInfoView;
@property (nonatomic, strong)MSNRelatedGoodsView *relatedView;

- (void)setGoodsInfo:(MSNGoodsItem*)item action:(void (^)(bool loaded))action;


@end
