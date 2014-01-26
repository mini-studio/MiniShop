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

@interface MSNShopInfoView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UIView *gradeView;
@property (nonatomic,strong)UILabel *sellerNickLabel;
@property (nonatomic,strong)UILabel *followerLabel;
@property (nonatomic,strong)UIImageView *accessoryImageView;
@end

@implementation MSNShopInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.imageView];
        CGFloat left = self.imageView.right + 6;
        CGFloat top = 4;
        CGFloat width = self.width-left-30;
        self.nameLabel = [self createLable:CGRectMake(left, top, width, 16) fontSize:16];
        [self addSubview:self.nameLabel];
        top = self.nameLabel.bottom + 4;
        self.gradeView = [[UIView alloc] initWithFrame:CGRectMake(left, top, width, 16)];
        [self addSubview:self.gradeView];
        top = self.gradeView.bottom + 4;
        self.sellerNickLabel = [self createLable:CGRectMake(left, top, width, 16) fontSize:14];
        [self addSubview:self.sellerNickLabel];
        top = self.sellerNickLabel.bottom + 4;
        self.followerLabel = [self createLable:CGRectMake(left, top, width, 16) fontSize:14];
        [self addSubview:self.followerLabel];
        
        self.accessoryImageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"rightarrow"]];
        self.accessoryImageView.center = CGPointMake(self.width-20, self.height/2);
        [self addSubview:self.accessoryImageView];
        
        self.eventButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.eventButton.frame = self.bounds;
        [self addSubview:self.eventButton];
    }
    return self;
}


- (UILabel *)createLable:(CGRect)frame fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor colorWithRGBA:0x414345FF];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

- (NSInteger)gradeValue:(NSInteger)grade
{
    if (grade>10000000) {
        return 45;
    }
    else if (grade>5000000) {
        return 44;
    }
    else if (grade>2000000) {
        return 43;
    }
    else if (grade>1000000) {
        return 42;
    }
    else if (grade>500000) {
        return 41;
    }
    else if (grade>200000) {
        return 35;
    }
    else if (grade>100000) {
        return 34;
    }
    else if (grade>20000) {
        return 33;
    }
    else if (grade>10000) {
        return 32;
    }
    else if (grade>5000) {
        return 25;
    }
    else if (grade>2000) {
        return 24;
    }
    else if (grade>1000) {
        return 23;
    }
    else if (grade>500) {
        return 22;
    }
    else if (grade>250) {
        return 21;
    }
    else if (grade>150) {
        return 15;
    }
    else if (grade>90) {
        return 14;
    }
    else if (grade>40) {
        return 13;
    }
    else if (grade>10) {
        return 12;
    }
    else if (grade>4) {
        return 11;
    }
    else {
        return 10;
    }
}

- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.nameLabel.text = shopInfo.shop_title;
    NSInteger gradeValue = [self gradeValue:shopInfo.shop_grade.intValue];
    int numbers = gradeValue%10;
    for (int index=0; index<numbers; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
        imageView.frame = CGRectMake(index*(24), 0, 18, 16);
        [self.gradeView addSubview:imageView];
    }
    self.sellerNickLabel.text = [NSString stringWithFormat:@"卖家：%@  %@",shopInfo.seller_nick,shopInfo.shop_address];
    if (shopInfo.shop_goods_num!=nil)  {
        self.followerLabel.text = [NSString stringWithFormat:@"%@人关注 %@件",shopInfo.shop_like_num,shopInfo.shop_goods_num];
    }
    else {
        self.followerLabel.text = [NSString stringWithFormat:@"%@人关注",shopInfo.shop_like_num];
    }
    if ( shopInfo.shop_logo.length >0 ) {
        __weak UIImageView *imageView = self.imageView;
        [imageView setImageWithURL:[NSURL URLWithString:shopInfo.shop_logo]  placeholderImage:[UIImage imageNamed:@"shop"] options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
        } failure:^(NSError *error) {
            
        }];

    }
}


@end
