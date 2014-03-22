//
//  MSShopInfoCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-10.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopInfoCell.h"
#import "UIColor+Mini.h"
#import "MiniUIButton+Mini.h"

@interface MSShopInfoCell()
@property (nonatomic,strong)UILabel *aliasName;
@end

@implementation MSShopInfoCell

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
        self.button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_button_normal"] highlightedBackGroundImage:[UIImage imageNamed:@"follow_button_selected"] title:@""];
        [self.button prefect];
        self.button.titleLabel.textColor = [UIColor colorWithRGBA:0xffecc8ff];
        [self addSubview:self.button];
        self.button.size = CGSizeMake(70, 30);
        self.detailTextLabel.height = 20;
        self.aliasName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.aliasName.backgroundColor = [UIColor clearColor];
        self.aliasName.font = [UIFont systemFontOfSize:14];
        self.aliasName.textColor = self.detailTextLabel.textColor;
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        
        self.shareButton = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_button_normal"] highlightedBackGroundImage:[UIImage imageNamed:@"follow_button_selected"] title:@"分享"];
        [self.button prefect];
        self.shareButton.titleLabel.textColor = [UIColor colorWithRGBA:0xffecc8ff];
        self.shareButton.size = CGSizeMake(40, 30);
        self.imageView.image = [UIImage imageNamed:@"news_online_icon"];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.button.hidden = NO;
    self.button.alpha = 1.0f;
    self.aliasName.text = nil;
    [self.aliasName removeFromSuperview];
    self.detailTextLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( self.showsShareButton )
    {
        self.textLabel.width = self.width - 140 - 30 ;
        self.shareButton.center = CGPointMake(self.width - self.shareButton.width/2 - 10, self.height/2);
        self.button.center = CGPointMake(self.shareButton.left - self.button.width/2 - 10, self.height/2);
    }
    else
    {
        self.textLabel.width = self.width - 100 - 30;
        self.button.center = CGPointMake(self.width - self.button.width/2 - 10, self.height/2);
    }
    self.imageView.frame = CGRectMake(10, 12, 16, 16);
    self.textLabel.origin = CGPointMake(30, 10);
    CGRect frame = self.textLabel.frame;
    frame.origin.y = self.textLabel.bottom;
    if ( self.detailTextLabel.text.length > 0 )
    {
        self.detailTextLabel.origin = CGPointMake(frame.origin.x, self.textLabel.bottom );
        self.detailTextLabel.hidden = NO;
        frame.origin.y = self.detailTextLabel.bottom;
    }
    else
    {
        self.detailTextLabel.hidden = YES;
    }
    if (self.aliasName.text.length > 0 )
    {
        self.aliasName.frame = frame;
        [self.detailTextLabel.superview addSubview:self.aliasName];
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

- (void)setShopInfo:(MSShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.textLabel.text = [_shopInfo realTitle];
    self.aliasName.text = [_shopInfo aliasTitle];
    self.button.enabled = YES;

    self.detailTextLabel.text = @"";
    if ( _shopInfo.shop_id == 0 )
    {
        if ( _shopInfo.cooperate == 1 )
        {
            [self.button setTitle:@"求过了" forState:UIControlStateNormal];
            self.button.enabled = NO;
        }
        else
        {
            [self.button setTitle:@"求收录" forState:UIControlStateNormal];
        }
        [MSShopInfoCell resetButtonState:self.button shopInfo:_shopInfo];
        self.detailTextLabel.text = [NSString stringWithFormat:@"求收录人数:%d",_shopInfo.num];
    }
    else
    {
        self.button.hidden = (shopInfo.like==1);
        [MSShopInfoCell resetButtonState:self.button shopInfo:shopInfo];
        if ( shopInfo.like_num > 0 )
        {
            self.detailTextLabel.text = [NSString stringWithFormat:@"共%d人关注",_shopInfo.like_num];
        }
        else
        {
             self.detailTextLabel.text = @"关注人数 0";
        }
    }
}

+ (void)resetButtonState:(MiniUIButton *)button shopInfo:(MSShopInfo*)shopInfo
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

+ (CGFloat)height:(MSShopInfo *)shopInfo
{
    if ( shopInfo.aliasTitle.length > 0 )
    {
        return 80;
    }
    else
    {
        return 50;
    }
}

@end
