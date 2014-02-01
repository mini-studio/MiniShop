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
#import "MSNShopInfoView.h"

@interface MSNShopInfoCell()
@property (nonatomic,strong)MSNShopInfoView *shopInfoView;
@property (nonatomic,strong)UIView *separatorView;
@property (nonatomic,strong)MiniUIButton *button;
@end

@implementation MSNShopInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 2, self.width-115, 85)];
        self.shopInfoView.eventButton = nil;
        self.shopInfoView.accessoryImageView = nil;
        [self addSubview:self.shopInfoView];
        self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.separatorView.backgroundColor = [UIColor colorWithRGBA:0xcb7275ff];
        [self addSubview:self.separatorView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"add"] highlightedImage:[UIImage imageNamed:@"add_hover"]];
        [self addSubview:self.button];
        [self.button addTarget:self action:@selector(actionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.separatorView.frame = CGRectMake(0, self.height-1, self.width, 1);
    self.button.center = CGPointMake(self.width-15-(self.button.width/2), self.height/2);
}

- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    self.shopInfoView.shopInfo = shopInfo;
    if (shopInfo.like==1) {
        [self.button setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.button setImage:[UIImage imageNamed:@"cancel_hover"] forState:UIControlStateHighlighted];
    }
    else {
        [self.button setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [self.button setImage:[UIImage imageNamed:@"add_hover"] forState:UIControlStateHighlighted];
    }
}

- (void)actionButtonTap:(MiniUIButton*)button
{
    if (self.shopInfo.like==0) {
        if (self.shopInfoDelegate!=nil) {
            [self.shopInfoDelegate favShop:self.shopInfo];
        }
    }
    else {
        if (self.shopInfoDelegate!=nil) {
            [self.shopInfoDelegate cancelFavShop:self.shopInfo];
        }
    }
}

+ (CGFloat)height:(MSNShopInfo *)shopInfo
{
    return 85;
}
@end
