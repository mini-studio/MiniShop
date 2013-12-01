//
//  MSTransformButton.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSTransformButton.h"

@interface MSTransformButton()
@property (nonatomic) int selectedIndex;
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
        
        self.slabel = [self titlelabel];
        self.slabel.hidden = YES;
        [self.button addSubview:self.slabel];
        
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (UILabel *)titlelabel
{
    UILabel *lable = [[UILabel alloc] initWithFrame:self.button.bounds];
    lable.font = [UIFont systemFontOfSize:18];
    lable.textAlignment = NSTextAlignmentCenter;
    return lable;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    self.label.text = items[0];
    self.selectedIndex = 0;
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    NSString *title = [self.items objectAtIndex:selectedIndex];
    self.slabel.text = title;
    self.slabel.top = self.height;
    self.slabel.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.label.bottom = 0;
        self.slabel.top = 0;
    }completion:^(BOOL finished) {
        self.slabel.hidden = YES;
        self.label.top = 0;
        self.label.text = title;
    }];
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