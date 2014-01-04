//
//  MSTransformButton.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSTransformButton.h"

@interface MSTransformButton()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UILabel *slabel;
@end

@implementation MSTransformButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        [self.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        self.label = [self titlelabel];
        [self.button addSubview:self.label];
        self.label.textAlignment = NSTextAlignmentLeft;
        
        self.slabel = [self titlelabel];
        self.slabel.hidden = YES;
        [self.button addSubview:self.slabel];
        self.slabel.textAlignment = NSTextAlignmentLeft;
        
        self.layer.masksToBounds = YES;
        [self setFontSize:16];
        [self setFontColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setFontColor:(UIColor *)fontColor
{
    _fontColor = fontColor;
    self.label.textColor = fontColor;
    self.slabel.textColor = fontColor;
}

- (void)setFontSize:(int)fontSize
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    self.label.font = font;
    self.slabel.font = font;
}

- (UILabel *)titlelabel
{
    CGRect frame = self.button.bounds;
    frame = CGRectInset(frame, 4, 0);
    UILabel *lable = [[UILabel alloc] initWithFrame:frame];
    lable.font = [UIFont systemFontOfSize:18];
    lable.textAlignment = NSTextAlignmentCenter;
    return lable;
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items defaultIndex:0];
}

- (void)setItems:(NSArray *)items defaultIndex:(int)index
{
    _items = items;
    self.label.text = items[index];
    [self setSelectedIndex:index animated:NO];
}

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated
{
    BOOL changed = (selectedIndex != _selectedIndex);
    _selectedIndex = selectedIndex;
    NSString *title = [self.items objectAtIndex:selectedIndex];
    self.slabel.text = title;
    self.slabel.top = self.height;
    self.slabel.hidden = NO;
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        self.label.bottom = 0;
        self.slabel.top = 0;
    }completion:^(BOOL finished) {
        self.slabel.hidden = YES;
        self.label.top = 0;
        self.label.text = title;
    }];
    if (changed)
        if (self.delegate!=nil)
            if ([self.delegate respondsToSelector:@selector(transformButtonValueChanged:)])
                [self.delegate transformButtonValueChanged:self];
}

- (void)setSelectedIndex:(int)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:YES];
}

- (void)buttonTap:(MiniUIButton *)button
{
    int index = self.selectedIndex+1;
    if ( index >= self.items.count ) {
        index = 0;
    }
    self.selectedIndex = index;
}

@end
