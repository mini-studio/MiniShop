//
//  MSNShopInfoView.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-7.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopInfoView.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Mini.h"
#import "MSNGradeView.h"

@interface MSNShopInfoView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)MSNGradeView *gradeView;
@property (nonatomic,strong)UILabel *sellerNickLabel;
@property (nonatomic,strong)UILabel *followerLabel;
@end

@implementation MSNShopInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 55, 55)];
        [self addSubview:self.imageView];
        CGFloat left = self.imageView.right + 8;
        CGFloat top = 14;
        CGFloat width = self.width-left-30;
        self.nameLabel = [self createLable:CGRectMake(left, top, width, 15) fontSize:15];
        [self addSubview:self.nameLabel];
        top = self.nameLabel.bottom + 6;
        self.gradeView = [[MSNGradeView alloc] initWithFrame:CGRectMake(left, top, width, 10)];
        [self addSubview:self.gradeView];
        top = self.gradeView.bottom + 6;
        self.sellerNickLabel = [self createLable:CGRectMake(left, top, width, 9) fontSize:9];
        [self addSubview:self.sellerNickLabel];
        top = self.sellerNickLabel.bottom + 2;
        self.followerLabel = [self createLable:CGRectMake(left, top, width, 9) fontSize:9];
        [self addSubview:self.followerLabel];
        
        self.accessoryImageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"rightarrow"]];
        
        self.eventButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

- (void)setEventButton:(MiniUIButton *)eventButton
{
    [_eventButton removeFromSuperview];
    _eventButton = eventButton;
    if (_eventButton!=nil) {
        [self addSubview:self.eventButton];
        self.eventButton.frame = self.bounds;
    }
}

- (void)setAccessoryImageView:(UIImageView *)accessoryImageView
{
    [_accessoryImageView removeFromSuperview];
    _accessoryImageView = accessoryImageView;
    if (_accessoryImageView!=nil) {
        [self addSubview:self.accessoryImageView];
        self.accessoryImageView.center = CGPointMake(self.width-20, self.height/2);
    }
    else {
        self.nameLabel.width = self.nameLabel.width + 30;
        self.gradeView.width = self.gradeView.width + 30;
        self.sellerNickLabel.width = self.sellerNickLabel.width + 30;
        self.followerLabel.width = self.followerLabel.width + 30;
    }
}


- (UILabel *)createLable:(CGRect)frame fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRGBA:0x414345FF];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.nameLabel.text = shopInfo.shop_title;
    //设置信誉等级
    [self.gradeView setGrade:[shopInfo gradeValue] shopType:shopInfo.shop_type];
    self.sellerNickLabel.text = [NSString stringWithFormat:@"卖家：%@  %@",shopInfo.seller_nick,shopInfo.shop_address];
    if (shopInfo.shop_goods_num!=nil)  {
        self.followerLabel.text = [NSString stringWithFormat:@"%@人关注 %@件",shopInfo.shop_like_num,shopInfo.shop_goods_num];
    }
    else {
        self.followerLabel.text = [NSString stringWithFormat:@"%@人关注",shopInfo.shop_like_num];
    }
    //shopInfo.shop_logo = @"http://logo.taobao.com//51/dd/T1e521XehlXXb1upjX";
    __PSELF__;
    if ( shopInfo.shop_logo.length >0 ) {
        __weak UIImageView *imageView = self.imageView;
        [imageView setImageWithURL:[NSURL URLWithString:shopInfo.shop_logo]  placeholderImage:[UIImage imageNamed:@"shop_logo"] options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
            pSelf.shopInfo.logo = image;
        } failure:^(NSError *error) {
        }];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"shop_logo"];
    }
}


@end
