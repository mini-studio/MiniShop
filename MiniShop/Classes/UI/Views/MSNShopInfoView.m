//
//  MSNShopInfoView.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-7.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopInfoView.h"
#import "UIImageView+WebCache.h"
@interface MSNShopInfoView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *addressLabel;
@property (nonatomic,strong)UILabel *sellerNickLabel;
@property (nonatomic,strong)UILabel *followerLabel;
@end

@implementation MSNShopInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.imageView];
        CGFloat left = self.imageView.right + 6;
        CGFloat top = 4;
        self.nameLabel = [self createLable:CGRectMake(left, top, self.width-left, 16)];
        [self addSubview:self.nameLabel];
        top = self.nameLabel.bottom + 4;
        self.addressLabel = [self createLable:CGRectMake(left, top, self.nameLabel.width, 16)];
        [self addSubview:self.addressLabel];
        top = self.addressLabel.bottom + 4;
        self.sellerNickLabel = [self createLable:CGRectMake(left, top, self.nameLabel.width, 16)];
        [self addSubview:self.sellerNickLabel];
        top = self.sellerNickLabel.bottom + 4;
        self.followerLabel = [self createLable:CGRectMake(left, top, self.nameLabel.width, 16)];
        [self addSubview:self.followerLabel];
    }
    return self;
}


- (UILabel *)createLable:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:12];
    return label;
}

- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.nameLabel.text = shopInfo.shop_title;
    self.addressLabel.text = shopInfo.shop_address;
    self.sellerNickLabel.text = shopInfo.seller_nick;
    self.followerLabel.text = [NSString stringWithFormat:@"%@人关注",shopInfo.shop_like_num];
    if ( shopInfo.shop_logo.length >0 ) {
        __weak UIImageView *imageView = self.imageView;
        [imageView setImageWithURL:[NSURL URLWithString:shopInfo.shop_logo]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
        } failure:^(NSError *error) {
            
        }];

    }
}


@end
