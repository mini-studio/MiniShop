//
//  MSNaviMenuView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNaviMenuView.h"

@interface MSNaviMenuView ()
@property (nonatomic,strong)UIScrollView *scrollview;
@property (nonatomic,strong)NSMutableArray *buttons;
@property (nonatomic,strong)UIView *slideView;
@end

@implementation MSNaviMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.buttons = [NSMutableArray array];
        self.scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollview];
        _selectedIndex = 0;
        self.slideView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollview.height-6, 0, 6)];
        self.slideView.backgroundColor = [UIColor whiteColor];
        [self.scrollview addSubview:self.slideView];
        self.scrollview.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    int count = self.buttons.count;
    int buttonsWidth = 0;
    for (int index = 0; index<count; index++) {
        MiniUIButton *button = self.buttons[index];
        [button sizeToFit];
        button.width = button.width + 8;
        button.left = buttonsWidth;
        button.frame = CGRectMake(buttonsWidth, 0, button.width, self.height);
        buttonsWidth += button.width;
    }
    self.scrollview.contentSize = CGSizeMake(buttonsWidth, self.scrollview.height);
    [self.scrollview bringSubviewToFront:self.slideView];
    
    //MiniUIButton *button = [self.buttons objectAtIndex:self.selectedIndex];
    //self.slideView.frame = CGRectMake(button.left, self.slideView.top, button.width, self.slideView.height);
    [self setSelectedIndex:_selectedIndex cascade:NO];
}

- (void)addMenuTitle:(NSString*)title userInfo:(id)userInfo
{
    MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    button.size = CGSizeMake(10, self.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.buttons addObject:button];
    [self.scrollview addSubview:button];
    button.userInfo = userInfo;
    [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (id)userInfoAtIndex:(int)index
{
    MiniUIButton *button = self.buttons[index];
    return button.userInfo;
}

- (void)setSelectedIndex:(int)selectedIndex
{
    [self setSelectedIndex:selectedIndex cascade:YES];
}

- (void)buttonTap:(MiniUIButton *)button
{
    NSInteger index = [self.buttons indexOfObject:button];
    self.selectedIndex = index;
}

- (void)setSelectedIndex:(int)selectedIndex cascade:(BOOL)cascade
{
    if ( selectedIndex >= self.buttons.count) {
        return;
    }
    int lastSelectedIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    MiniUIButton *button = [self.buttons objectAtIndex:self.selectedIndex];
    self.slideView.width = button.width;
    CGFloat contentOffsetX = self.scrollview.contentOffset.x;
    if (self.scrollview.contentSize.width > self.scrollview.width){
        if ( lastSelectedIndex > _selectedIndex ) {
            if ((button.left - self.scrollview.contentOffset.x) < button.width) {
                if ( selectedIndex > 0 ) {
                    contentOffsetX = ((MiniUIButton*)[self.buttons objectAtIndex:(self.selectedIndex-1)]).left;
                }
                else {
                    contentOffsetX = 0;
                }
            }
        }
        else if ( lastSelectedIndex < _selectedIndex) {
            if ((self.scrollview.width -( button.right-contentOffsetX)) < button.width) {
                if ( selectedIndex < (self.buttons.count-1) ) {
                    contentOffsetX = ((MiniUIButton*)[self.buttons objectAtIndex:(self.selectedIndex+1)]).right-self.scrollview.width;
                }
                else {
                    contentOffsetX = self.scrollview.contentSize.width-self.scrollview.width;
                }
            }
        }
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.slideView.centerX = button.centerX;
        self.scrollview.contentOffset = CGPointMake(contentOffsetX, self.scrollview.contentOffset.y);
    }];
    if ( cascade ) {
        if (self.selected) {
            if ( selectedIndex <= self.buttons.count-1 ) {
                id userInfo = ((MiniUIButton*)[self.buttons objectAtIndex:selectedIndex]).userInfo;
                self.selected(userInfo);
            }
        }
    }
}

- (void)setSlidePercent:(CGFloat)percent left:(BOOL)left
{
    CGFloat leftPosition = self.scrollview.contentSize.width*percent;
    if (leftPosition < 0) {
        leftPosition = 0;
    }
    else {
        CGFloat l = self.scrollview.contentSize.width-self.slideView.width;
        if ( leftPosition > l ) {
            leftPosition = l;
        }
    }
    if ( left ) {
        if ( leftPosition < self.slideView.left )
        return;
    }
    else {
        if ( leftPosition > self.slideView.left )
            return;
    }
    
    self.slideView.left = leftPosition;
}

@end
