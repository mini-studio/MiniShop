//
//  MSNDetailToolBar.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNDetailToolBar.h"
#import "UIColor+Mini.h"

@interface MSNImageLabel : UIView
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;
@end

@implementation MSNImageLabel
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:self.imageView];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)sizeToFit
{
    [super sizeToFit];
    self.label.width = self.width-self.imageView.width-6;
    if (self.label.text.length==0) {
        self.imageView.height = 0;
        self.label.height = 0;
        self.height = 0;
    }
    else {
        self.imageView.size = CGSizeMake(20, 20);
        [self.label sizeToFit];
        self.label.origin = CGPointMake(26, 0);
        self.height = self.label.height;
    }
}

@end

@interface MSNDetailToolBar()
@property (nonatomic,strong)UIScrollView *contentView;

@property (nonatomic,strong)MSNImageLabel *priceHistoryIntroLabel;
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

- (UILabel*)createLabel:(CGRect)frame fontSize:(int)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor colorWithRGBA:0x414345FF];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    return label;
}

- (void)initSubViews
{
    self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.contentView];
    self.goodsNameLabel = [self createLabel:CGRectMake(10, 10, self.width-20, 30) fontSize:16];
    [self.contentView addSubview:self.goodsNameLabel];
    self.goodsPriceLabel = [self createLabel:CGRectMake(10, self.goodsNameLabel.bottom+6, 100, 30) fontSize:21];
    [self.contentView addSubview:self.goodsPriceLabel];
    
    self.buybutton = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:@"购买"];
    self.buybutton.frame = CGRectMake(self.width - 100, self.goodsPriceLabel.top, 90, 30);
    [self.contentView addSubview:self.buybutton];
    
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, 85)];
    [self.contentView addSubview:self.shopInfoView];
    
    self.priceHistoryIntroLabel = [[MSNImageLabel alloc] initWithFrame:CGRectMake(10, 0, self.width-20, 0)];
    self.priceHistoryIntroLabel.imageView.image = [UIImage imageNamed:@"arrowdown"];
    [self addSubview:self.priceHistoryIntroLabel];
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
}

- (void)sizeToFit
{
    [super sizeToFit];
    CGFloat width = self.width-20;
    self.goodsNameLabel.width = width;
    [self.goodsNameLabel sizeToFit];
    self.goodsPriceLabel.width = width;
    [self.goodsPriceLabel sizeToFit];
    self.goodsPriceLabel.top = self.goodsNameLabel.bottom+6;
    self.buybutton.top = self.goodsPriceLabel.top;
    [self.priceHistoryIntroLabel sizeToFit];
    self.priceHistoryIntroLabel.top = self.buybutton.bottom + 6;
    self.shopInfoView.top = self.priceHistoryIntroLabel.bottom;
    self.height = self.shopInfoView.bottom;
    self.contentView.height = self.height;
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
