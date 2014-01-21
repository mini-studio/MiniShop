//
//  MSNDetailToolBar.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNDetailToolBar.h"
#import "UIColor+Mini.h"
#import "MSNShopInfoView.h"

@implementation MSNDetailToolFeatureView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    CGFloat width = 60;
    CGFloat height = 30;
    CGFloat top = (self.height-30)/2;
    CGFloat left = (self.width-3*width)/2;
    self.buyButton = [self createButton:@"购买" frame:CGRectMake(left+5, top, width-10, height)];
    left += (width+10);
    self.favButton = [self createButton:@"收藏" frame:CGRectMake(left, top, width-10, height)];
    left += (width+15);
    self.shareButton = [self createButton:@"分享" frame:CGRectMake(left, top, width-10, height)];
    [self addSubview:self.buyButton];
    [self addSubview:self.favButton];
    [self addSubview:self.shareButton];
}

- (MiniUIButton*)createButton:(NSString*)title frame:(CGRect)frame
{
    MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:title];
    button.frame = frame;
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface MSNDetailToolBar()
@property (nonatomic,strong)UIScrollView *contentView;
@property (nonatomic,strong)MSNShopInfoView* shopInfoView;

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
    self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.contentView];
    UIImage *image = [MiniUIImage imageNamed:@"tool_bar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.bounds;
    [self.contentView addSubview:imageView];
    
    self.goodsNameLabel = [self createLabel:CGRectMake(10, 10, self.width-20, 30)];
    [self.contentView addSubview:self.goodsNameLabel];
    self.goodsPriceLabel = [self createLabel:CGRectMake(10, self.goodsNameLabel.bottom, 100, 30)];
    [self.contentView addSubview:self.goodsPriceLabel];
    
    self.buybutton = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:@"购买"];
    self.buybutton.frame = CGRectMake(self.width - 100, self.goodsPriceLabel.top, 90, 30);
    [self.contentView addSubview:self.buybutton];
    
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, 80)];
    [self.contentView addSubview:self.shopInfoView];
    
}

- (void)sizeToFit
{
    [super sizeToFit];
    CGFloat width = self.width-20;
    self.goodsPriceLabel.width = width;
    [self.goodsNameLabel sizeToFit];
    self.goodsPriceLabel.width = width;
    [self.goodsPriceLabel sizeToFit];
    self.goodsPriceLabel.top = self.goodsNameLabel.bottom;
    self.buybutton.top = self.goodsPriceLabel.top;
    self.shopInfoView.top = self.buybutton.bottom;
    self.height = self.shopInfoView.bottom;
}

- (void)setGoodsInfo:(MSNGoodsItem*)item
{
    
    self.goodsNameLabel.text = item.goods_title;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %@",item.goods_marked_price];
    __PSELF__;
    [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            item.detail = data;
            pSelf.shopInfoView.shopInfo = item.detail.shop_info;
            [pSelf setNeedsLayout];
        }
    }];
}

@end
