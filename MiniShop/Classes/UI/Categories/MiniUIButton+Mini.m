//
//  MiniUIButton+LS.m
//  xcmg
//
//  Created by Wuquancheng on 12-11-23.
//  Copyright (c) 2012年 mini. All rights reserved.
//

#import "MiniUIButton+Mini.h"
#import "UIColor+Mini.h"
#import <objc/runtime.h>

NSString *MINI_ButtonHanldeKey = @"MINI_ButtonHanldeKey";
typedef void(^MINIButtonTouchupHanlder)(MiniUIButton *button);


@implementation MiniUIButton (LS)

- (void)setTouchupHandler:(void (^)(MiniUIButton *button))handler
{
    [self removeTarget:self action:@selector(handleButtonTouchup:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(handleButtonTouchup:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self, (__bridge const void *)(MINI_ButtonHanldeKey), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)handleButtonTouchup:(MiniUIButton *)button
{
    MINIButtonTouchupHanlder handler  = (MINIButtonTouchupHanlder)objc_getAssociatedObject(self,(__bridge const void *)(MINI_ButtonHanldeKey));    
    if(handler)
    {
        handler(button);
    }
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

@implementation UIButton (prefect)

- (void)prefect
{
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self setTitleColor:[UIColor colorWithRGBA:0xbf6241FF] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor colorWithRGBA:0xe9a577FF] forState:UIControlStateNormal];
    self.titleLabel.shadowOffset = CGSizeMake(0, 0.5);
}

- (void)prefectDefault
{
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
