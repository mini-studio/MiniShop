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




@implementation MiniUIButton (LS)

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

+ (MiniUIButton*)createToolBarButton:(NSString*)title imageName:(NSString*)imageName hImageName:(NSString*)hImageName
{
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:hImageName]];
    button.size = CGSizeMake(44, 44);
    [button setTitleColor:[UIColor colorWithRGBA:0xe74764FF] forState:UIControlStateNormal];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.height-14, button.width, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRGBA:0xe74764FF];
    label.font = [UIFont systemFontOfSize:8];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [button addSubview:label];
    return button;
}


@end
