//
//  MSNSearchShopTitleView.m
//  MiniShop
//
//  Created by Wuquancheng on 14-2-2.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNSearchShopTitleView.h"
#import "RTLabel.h"
#import "MSTransformButton.h"
#import "UIColor+Mini.h"

@interface MSNSearchShopTitleView()
@property (nonatomic,strong)RTLabel *keylabel;
@end


@implementation MSNSearchShopTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    self.keylabel= [[RTLabel alloc] initWithFrame:CGRectMake(10, 7, self.width-115-10, 14)];
    _keylabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_keylabel];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.width-115, 0, 1, self.height)];
    separator.backgroundColor = [UIColor colorWithRGBA:0xd14c60ff];
    [self addSubview:separator];
    

    _transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(self.width-100, 0, 80, 28)];
    _transformButton.fontColor = [UIColor colorWithRGBA:0xd14c60ff];
    _transformButton.fontSize = 12;
    [self addSubview:_transformButton];
    
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"order"] highlightedImage:[UIImage imageNamed:@"order_hover"]];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    button.frame = CGRectMake(_transformButton.right, 0, 28, 28);
    [self addSubview:button];
    [button setTouchupHandler:^(MiniUIButton *button) {
        _transformButton.selectedIndex = _transformButton.selectedIndex+1;
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, self.width, 1)];
    line.backgroundColor = [UIColor colorWithRGBA:0xcb7275ff];
    [self addSubview:line];
}


- (void)setKeyWord:(NSString *)keyWord
{
    [_keylabel setText:[NSString stringWithFormat:@"<font color='#414345'>销售</font><font color='#d14c60'>%@</font><font color='#414345'>的精品店</font>",keyWord]];
}

@end
