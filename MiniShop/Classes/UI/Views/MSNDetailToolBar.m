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
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        [self addSubview:self.imageView];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont systemFontOfSize:12];
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.top = 2;
}

- (void)sizeToFit
{
    [super sizeToFit];
    self.label.width = self.width-18;
    if (self.label.text.length==0) {
        self.imageView.height = 0;
        self.label.height = 0;
        self.height = 0;
    }
    else {
        self.imageView.size = CGSizeMake(12, 12);
        [self.label sizeToFit];
        self.label.origin = CGPointMake(18, 0);
        self.height = self.label.height;
    }
}

- (void)setTextColor:(UIColor*)color
{
    self.label.textColor = color;
}
@end

@interface MSNDetailToolBar()
@property (nonatomic,strong)UIScrollView *contentView;
@property (nonatomic,strong)UILabel      *discountLabel;
@property (nonatomic,strong)MSNImageLabel *priceHistoryIntroLabel;
@property (nonatomic,strong)UILabel     *startTimeLabel;
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
    
    self.discountLabel = [self createLable:12 textColor:[UIColor colorWithRGBA:0xC00000ff]];
    [self.contentView addSubview:self.discountLabel];
    
    self.buybutton = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:@"购买"];
    self.buybutton.frame = CGRectMake(self.width - 100, self.goodsPriceLabel.top, 90, 30);
    [self.contentView addSubview:self.buybutton];
    
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, 85)];
    [self.contentView addSubview:self.shopInfoView];
    
    self.priceHistoryIntroLabel = [[MSNImageLabel alloc] initWithFrame:CGRectMake(10, 0, self.width-20, 0)];
    self.priceHistoryIntroLabel.imageView.image = [UIImage imageNamed:@"arrowdown"];
    [self.priceHistoryIntroLabel setTextColor:[UIColor colorWithRGBA:0xd24d62ff]];
    [self addSubview:self.priceHistoryIntroLabel];
    
    self.startTimeLabel = [self createLable:12 textColor:[UIColor colorWithRGBA:0x414345ff]];
    self.startTimeLabel.size = CGSizeMake(self.width-20, 12);
    [self.contentView addSubview:self.startTimeLabel];
    
}

- (UILabel*)createLable:(CGFloat)height textColor:(UIColor*)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:height];
    label.textColor = textColor;
    return label;
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
    if (self.discountLabel.text.length>0) {
        self.discountLabel.width = 50;
        [self.discountLabel sizeToFit];
        self.discountLabel.origin = CGPointMake(self.goodsPriceLabel.right+10, self.goodsPriceLabel.bottom-self.discountLabel.height);
    }
    else {
        self.discountLabel.size = CGSizeZero;
    }
    self.buybutton.top = self.goodsPriceLabel.top;
    [self.priceHistoryIntroLabel sizeToFit];
    self.priceHistoryIntroLabel.left = 10;
    self.priceHistoryIntroLabel.top = self.buybutton.bottom + 6;
    [self.startTimeLabel sizeToFit];
    self.startTimeLabel.origin = CGPointMake(10, self.priceHistoryIntroLabel.bottom);
    self.shopInfoView.top = self.startTimeLabel.bottom;
    self.height = self.shopInfoView.bottom;
    self.contentView.height = self.height;
}

- (void)setGoodsInfo:(MSNGoodsItem*)item action:(void (^)(bool loaded))action
{
    self.goodsNameLabel.text = item.goods_title;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %@",item.goods_sale_price];
    self.discountLabel.text = [item discountMessage];
    self.priceHistoryIntroLabel.label.text = item.price_history_intro;
    self.startTimeLabel.text = [NSString stringWithFormat:@"上架时间 %@",item.goods_sales_intro];;
    __PSELF__;
    [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, MSNGoodsDetail* data, id userInfo, BOOL cache) {
        if (error==nil) {
            item.detail = data;
            item.like_goods = data.info.goods_info.like_goods;
            pSelf.shopInfoView.shopInfo = item.detail.shop_info;
            item.goods_sales_intro = data.info.goods_info.goods_sales_intro;
            item.price_history_intro = data.info.goods_info.price_history_intro;
            pSelf.startTimeLabel.text=[NSString stringWithFormat:@"上架时间 %@",item.goods_sales_intro];
            pSelf.priceHistoryIntroLabel.label.text = item.price_history_intro;
            [pSelf sizeToFit];
            [pSelf setNeedsLayout];
            action(YES);
        }
    }];
}

@end
