//
//  MSNDetailToolBar.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-14.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNDetailToolBar.h"
#import "UIColor+Mini.h"
#import "MiniUIPhotoImageView.h"
#import "UIImageView+WebCache.h"
#import "MSNDetailViewController.h"

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

@interface MSNRelatedGoodsView()
@property(nonatomic, strong)MiniUIPhotoImageView * leftImageView;
@property(nonatomic, strong)MiniUIPhotoImageView * rightImageView;
@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)NSArray * goodsItems;
@property(nonatomic, strong)NSArray * imageViews;
@end

@implementation MSNRelatedGoodsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, self.width-20, 12)];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _leftImageView = [[MiniUIPhotoImageView alloc] initWithFrame:CGRectZero];
        _rightImageView = [[MiniUIPhotoImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleLabel];
        [self addSubview:_leftImageView];
        [self addSubview:_rightImageView];
        self.imageViews = @[_leftImageView,_rightImageView];
        _titleLabel.text = @"相关推荐";
        [_leftImageView addTarget:self selector:@selector(handleImageViewClick:) userInfo:@"0"];
        [_rightImageView addTarget:self selector:@selector(handleImageViewClick:) userInfo:@"1"];
    }
    return self;
}

- (void)sizeToFit
{
   [super sizeToFit];
    if (self.goodsItems.count==0) {
        self.height = 0;
        self.titleLabel.height=0;
        self.leftImageView.height = 0;
        self.rightImageView.height = 0;
    }
    else {
        _titleLabel.height = 10;
        CGFloat imageHeight =  self.width/2;
        self.height = imageHeight +_titleLabel.height + 20;
        for (int index=0;index<2&&index<_goodsItems.count;index++) {
            __block MiniUIPhotoImageView *imageView = self.imageViews[index];
            MSNGoodsItem * item = (MSNGoodsItem *)self.goodsItems[index];
            [imageView.imageView setImageWithURL:[NSURL URLWithString:item.middle_image_url] placeholderImage:nil
                                         options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
                        imageView.image = image;
                    } failure:^(NSError *error) {

                    }];
        }

        self.leftImageView.frame = CGRectMake(0, _titleLabel.bottom+10, self.height,imageHeight);
        self.rightImageView.frame = CGRectMake(self.width/2, self.leftImageView.top, self.height,imageHeight);
    }
}

- (void)handleImageViewClick:(MiniUIButton *)button
{
    int index = [button.userInfo integerValue];
    if (index<self.goodsItems.count) {
        MSNGoodsItem * item = (MSNGoodsItem *)self.goodsItems[index];
        MSNDetailViewController *controller = [[MSNDetailViewController alloc] init];
        controller.items = @[item];
        [[MSSystem sharedInstance].controller.navigationController pushViewController:controller animated:YES];
    }
}

@end


@interface MSNDetailToolBar()
@property (nonatomic,strong)UIScrollView *contentView;
@property (nonatomic,strong)UILabel      *discountLabel;
@property (nonatomic,strong)MSNImageLabel *priceHistoryIntroLabel;
@property (nonatomic,strong)UILabel     *startTimeLabel;

@property (nonatomic, strong)UIView *infoView;

@end

@implementation MSNDetailToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.hidden = YES;
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
    self.infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    self.infoView.backgroundColor = [UIColor colorWithRGBA:0xfdf4f2AA];
    self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];

    [self.contentView addSubview:self.infoView];
    [self addSubview:self.contentView];

    self.goodsNameLabel = [self createLabel:CGRectMake(10, 10, self.width-20, 30) fontSize:16];
    [self.infoView addSubview:self.goodsNameLabel];
    self.goodsPriceLabel = [self createLabel:CGRectMake(10, self.goodsNameLabel.bottom+6, 100, 30) fontSize:21];
    [self.infoView addSubview:self.goodsPriceLabel];
    
    self.discountLabel = [self createLabel:12 textColor:[UIColor colorWithRGBA:0xC00000ff]];
    [self.infoView addSubview:self.discountLabel];
    
    self.buyButton = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:@"购买"];
    self.buyButton.frame = CGRectMake(self.width - 100, self.goodsPriceLabel.top, 90, 30);
    [self.infoView addSubview:self.buyButton];

    self.priceHistoryIntroLabel = [[MSNImageLabel alloc] initWithFrame:CGRectMake(10, 0, self.width-20, 0)];
    self.priceHistoryIntroLabel.imageView.image = [UIImage imageNamed:@"arrowdown"];
    [self.priceHistoryIntroLabel setTextColor:[UIColor colorWithRGBA:0xd24d62ff]];
    [self.infoView addSubview:self.priceHistoryIntroLabel];
    
    self.startTimeLabel = [self createLabel:12 textColor:[UIColor colorWithRGBA:0x414345ff]];
    self.startTimeLabel.size = CGSizeMake(self.width-20, 12);
    [self.infoView addSubview:self.startTimeLabel];

    self.relatedView = [[MSNRelatedGoodsView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    [self.contentView addSubview:self.relatedView];

    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width, 85)];
    self.shopInfoView.backgroundColor = [UIColor colorWithRGBA:0xfdf4f2AA];
    [self.contentView addSubview:self.shopInfoView];

    
}

- (UILabel*)createLabel:(CGFloat)height textColor:(UIColor*)textColor
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
    self.buyButton.top = self.goodsPriceLabel.top;
    [self.priceHistoryIntroLabel sizeToFit];
    self.priceHistoryIntroLabel.left = 10;
    self.priceHistoryIntroLabel.top = self.buyButton.bottom + 6;
    [self.startTimeLabel sizeToFit];
    self.startTimeLabel.origin = CGPointMake(10, self.priceHistoryIntroLabel.bottom+6);
    self.infoView.height = self.startTimeLabel.bottom+7;
    
    self.shopInfoView.top = self.infoView.bottom;
    
    [self.relatedView sizeToFit];
    self.relatedView.origin = CGPointMake(0, self.shopInfoView.bottom);
    
    self.height = self.relatedView.bottom+2;
    self.contentView.height = self.height;
}

- (void)display
{
    self.contentView.hidden = NO;
}

- (void)setGoodsInfo:(MSNGoodsItem*)item action:(void (^)(bool loaded))action
{
    self.goodsNameLabel.text = item.goods_title;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %@",item.goods_sale_price];
    self.discountLabel.text = [item discount];
    self.priceHistoryIntroLabel.label.text = item.price_history_intro;
    self.startTimeLabel.text = @"";
    __PSELF__;
    [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, MSNGoodsDetail* data, id userInfo, BOOL cache) {
        if (error==nil) {
            item.detail = data;
            item.like_goods = data.info.goods_info.like_goods;
            pSelf.shopInfoView.shopInfo = item.detail.shop_info;
            item.goods_sales_intro = data.info.goods_info.goods_sales_intro;
            item.price_history_intro = data.info.goods_info.price_history_intro;
            pSelf.priceHistoryIntroLabel.label.text = item.price_history_intro;
            pSelf.startTimeLabel.text=[NSString stringWithFormat:@"上架时间 %@  最新售出%@笔",item.goods_sales_intro,item.goods_sale_num];
            pSelf.relatedView.goodsItems = data.info.collocation_info;
            [pSelf display];
            [pSelf sizeToFit];
            [pSelf setNeedsLayout];
            action(YES);
        }
    }];
}

@end
