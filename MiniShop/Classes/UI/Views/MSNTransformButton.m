//
//  MSNTransformButton.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNTransformButton.h"

@interface MSNTransformButton()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UILabel *slabel;
@property (nonatomic,strong) MiniUIButton *button;
@property (nonatomic,strong) MiniUIButton *accessorybutton;
@end

@implementation MSNTransformButton

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.accessorybutton!=nil) {
        self.accessorybutton.center = CGPointMake(self.width-self.accessorybutton.width/2, self.height/2);
        self.label.width = self.slabel.width = self.width-self.accessorybutton.width;
    }
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
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage himage:(UIImage *)hImage
{
    self.accessorybutton = [MiniUIButton buttonWithImage:accessoryImage highlightedImage:hImage];
    [self addSubview:self.accessorybutton];
    __PSELF__;
    [self.accessorybutton setTouchupHandler:^(MiniUIButton *button) {
        pSelf.selectedIndex = pSelf.selectedIndex+1;
    }];
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items defaultIndex:0];
}

- (id)selectedValue
{
    return [self.values objectAtIndex:self.selectedIndex];
}

- (void)setItems:(NSArray *)items defaultIndex:(int)index
{
    _items = items;
    self.label.text = items[index];
    [self setSelectedIndex:index animated:NO];
}

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated withEvent:(BOOL)withEvent
{
    if (selectedIndex<0) {
        selectedIndex = self.items.count-1;
    }
    else if (selectedIndex>=self.items.count){
        selectedIndex = 0;
    }
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
    if (withEvent && changed && self.delegate!=nil) {
        if ([self.delegate respondsToSelector:@selector(transformButtonValueChanged:)]) {
            [self.delegate transformButtonValueChanged:self];
        }
    }
}

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated
{
    [self setSelectedIndex:selectedIndex animated:animated withEvent:YES];
}

- (void)setSelectedIndex:(int)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:YES];
}

- (void)buttonTap:(MiniUIButton *)button
{
    int index = self.selectedIndex+1;
    self.selectedIndex = index;
}

@end
