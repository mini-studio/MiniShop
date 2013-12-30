//
//  MSNShopInfoCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNShopInfoCell.h"
#import "UIColor+Mini.h"
#import "MiniUIButton+Mini.h"

@interface MSNShopInfoCell()
@property (nonatomic,strong)UILabel *addressLabel;
@property (nonatomic,strong)UILabel *sellerLabel;
@property (nonatomic,strong)UILabel *messageLabel;
@end

@implementation MSNShopInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithRGBA:0x9E2929FF];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.height = 20;
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        self.button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_button_normal"] highlightedBackGroundImage:[UIImage imageNamed:@"follow_button_selected"] title:@""];
        [self.button prefect];
        self.button.titleLabel.textColor = [UIColor colorWithRGBA:0xffecc8ff];
        [self addSubview:self.button];
        self.button.size = CGSizeMake(70, 30);
        self.detailTextLabel.height = 20;
        self.addressLabel = [self createLabel];
        self.sellerLabel = [self createLabel];
        self.messageLabel = [self createLabel];
        self.shareButton = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_button_normal"] highlightedBackGroundImage:[UIImage imageNamed:@"follow_button_selected"] title:@"分享"];
        [self.button prefect];
        self.shareButton.titleLabel.textColor = [UIColor colorWithRGBA:0xffecc8ff];
        self.shareButton.size = CGSizeMake(40, 30);
        self.imageView.image = [UIImage imageNamed:@"news_online_icon"];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRGBA:0xefefefff];
    }
    return self;
}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = self.detailTextLabel.textColor;
    return label;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.button.hidden = NO;
    self.button.alpha = 1.0f;
    self.addressLabel.text = nil;
    [self.addressLabel removeFromSuperview];
    [self.sellerLabel removeFromSuperview];
    [self.messageLabel removeFromSuperview];
    self.detailTextLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( self.showsShareButton ) {
        self.textLabel.width = self.width - 140 - 30 ;
        self.shareButton.center = CGPointMake(self.width - self.shareButton.width/2 - 10, self.height/2);
        self.button.center = CGPointMake(self.shareButton.left - self.button.width/2 - 10, self.height/2);
    }
    else {
        self.textLabel.width = self.width - 100 - 30;
        self.button.center = CGPointMake(self.width - self.button.width/2 - 10, self.height/2);
    }
    self.imageView.frame = CGRectMake(10, 12, 16, 16);
    self.textLabel.origin = CGPointMake(30, 10);
    CGRect frame = self.textLabel.frame;
    frame.origin.y = self.textLabel.bottom;
    if ( self.detailTextLabel.text.length > 0 ) {
        self.detailTextLabel.origin = CGPointMake(frame.origin.x, self.textLabel.bottom );
        self.detailTextLabel.hidden = NO;
        frame.origin.y = self.detailTextLabel.bottom;
    }
    else {
        self.detailTextLabel.hidden = YES;
    }
    if (self.addressLabel.text.length > 0 ) {
        self.addressLabel.frame = frame;
        [self addSubview:self.addressLabel];
        frame.origin.y = self.addressLabel.bottom;
    }
    if (self.sellerLabel.text.length>0) {
        self.sellerLabel.frame = frame;
        [self addSubview:self.sellerLabel];
        frame.origin.y = self.sellerLabel.bottom;
    }
    if (self.messageLabel.text.length>0) {
        self.messageLabel.frame = frame;
        [self addSubview:self.messageLabel];
    }
}

- (void)setShowsShareButton:(BOOL)showsShareButton
{
    _showsShareButton = showsShareButton;
    if ( self.showsShareButton )
    {
        [self addSubview:self.shareButton];
    }
    else
    {
        [self.shareButton removeFromSuperview];
    }
}

- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.textLabel.text = [_shopInfo shop_title];
    self.addressLabel.text = [_shopInfo shop_address];
    self.sellerLabel.text = [_shopInfo seller_nick];
    self.messageLabel.text = [NSString stringWithFormat:@"%@人关注 %@件宝贝",shopInfo.shop_like_num,shopInfo.shop_goods_num];
    self.button.enabled = YES;
    if ( _shopInfo.shop_id.intValue == -100  ) {
        self.button.hidden = YES;
    }
    else {
        self.button.hidden = NO;
    }
    self.detailTextLabel.text = @"";
    self.button.userInfo = shopInfo;
    [MSNShopInfoCell resetButtonState:self.button shopInfo:shopInfo];
}

+ (void)resetButtonState:(MiniUIButton *)button shopInfo:(MSNShopInfo*)shopInfo
{
    if ( shopInfo.shop_id == 0 )
    {
        [button setBackgroundImage:[UIImage imageNamed:@"follow_button_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"follow_button_selected"] forState:UIControlStateHighlighted];
        [button prefect];
    }
    else {
        if ( shopInfo.like==0 )
        {
            [button setTitle:@"✚ 关注" forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"follow_button_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"follow_button_selected"] forState:UIControlStateHighlighted];
            [button prefect];
        }
        else
        {
            [button setTitle:@"取消关注" forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"unfollow_button_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"unfollow_button_selected"] forState:UIControlStateHighlighted];
            [button prefectDefault];
        }
    }
}

+ (CGFloat)height:(MSNShopInfo *)shopInfo
{
    return 86;
}
@end
