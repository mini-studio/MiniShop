//
//  MSNDetailToolBar.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNDetailToolBar.h"
#import "UIColor+Mini.h"

@interface MSNDetailToolBar()
@end

@implementation MSNDetailToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (UILabel*)createLabel:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor colorWithRGBA:0xEEEEEEEE];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    return label;
}

- (void)initSubViews
{
    UIImage *image = [MiniUIImage imageNamed:@"tool_bar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.bounds;
    [self addSubview:imageView];
    
    self.goodsNameLabel = [self createLabel:CGRectMake(10, 10, self.width-20, 30)];
    [self addSubview:self.goodsNameLabel];
    self.goodsPriceLabel = [self createLabel:CGRectMake(10, self.goodsNameLabel.bottom, 100, 30)];
    [self addSubview:self.goodsPriceLabel];
    
    self.button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:@"购买"];
    self.button.frame = CGRectMake(self.width - 100, self.goodsPriceLabel.top, 90, 30);
    [self addSubview:self.button];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.width-20;
    self.goodsPriceLabel.width = width;
    [self.goodsNameLabel sizeToFit];
    self.goodsPriceLabel.width = width;
    [self.goodsPriceLabel sizeToFit];
    self.goodsPriceLabel.top = self.goodsNameLabel.bottom;
    self.button.top = self.goodsPriceLabel.top;
}
- (void)setGoodsInfo:(MSNGoodsItem*)item
{
    self.goodsNameLabel.text = item.goods_title;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %@",item.goods_marked_price];
    __PSELF__;
    [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            item.detail = data;
            [pSelf setNeedsLayout];
        }
    }];
}

@end
