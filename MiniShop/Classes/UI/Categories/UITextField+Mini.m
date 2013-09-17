//
//  UITextField+Mini.m
//  lel
//
//  Created by Wuquancheng on 13-7-7.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "UITextField+Mini.h"

@implementation UITextField (Mini)

- (void)setLeftTitle:(NSString *)title color:(UIColor*)color placeholder:(NSString *)placeholder
{
    if ( title.length > 0 )
    {
        UILabel *left = [[UILabel alloc] initWithFrame:CGRectZero];
        left.backgroundColor = [UIColor clearColor];
        left.textColor = color;
        left.font = self.font;
        left.textAlignment = NSTextAlignmentCenter;
        left.text = title;
        [left sizeToFit];
        left.width += 8;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = left;
    }
    self.placeholder = placeholder;
}

- (void)setBottomLine:(UIColor*)color
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    view.backgroundColor = color;
    view.top = self.height-1;
    [self addSubview:view];
}

@end
