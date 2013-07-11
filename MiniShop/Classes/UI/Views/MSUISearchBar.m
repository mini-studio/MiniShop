//
//  MSUISearchBar.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUISearchBar.h"

@implementation MSUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    if([view isKindOfClass:[UIButton class]])
    {
        UIButton *btn = (UIButton *)view;
        [btn setTitle:@"取消"  forState:UIControlStateNormal];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
