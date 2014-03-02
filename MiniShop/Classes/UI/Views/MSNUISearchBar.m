//
//  MSNUISearchBar.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNUISearchBar.h"
#import "MSNTransformButton.h"
#import "UIColor+Mini.h"

@interface InnerUISearchBar : UISearchBar

@end

@implementation InnerUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageNamed:@"close_s_hover"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"close_s"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }
    return self;
}

- (void)addSubview:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)view;
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    [super addSubview:view];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end

@interface MSNUISearchBar()<UISearchBarDelegate>
@property (nonatomic,strong)InnerUISearchBar *searchBar;
@property (nonatomic,strong)MiniUIButton *watcherButton;

@end

@implementation MSNUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showCancelButtonWhenEdit = YES;
        self.backgroundColor = NAVI_BG_COLOR;
        CGRect frame = self.bounds;
        frame.size = CGSizeMake(self.width, self.height);
        self.searchBar = [[InnerUISearchBar alloc] initWithFrame:frame];
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor clearColor];
        [self addSubview:self.searchBar];
        self.watcherButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.watcherButton.backgroundColor = [UIColor colorWithRGBA:0x00000055];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [self.watcherButton addTarget:self action:@selector(watcherButtonTouchup:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)topSuperView
{
    UIView *superView = [self superview];
    while (superView!=nil) {
        if ( CGSizeEqualToSize(superView.size , WINDOW.size)) {
            return superView;
        }
        superView = [superView superview];
    }
    return nil;
}

- (void)keyboardWillShow:(NSNotification*)noti
{
    CGFloat f = [UIScreen mainScreen].bounds.size.height-64;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    if (self.inView!=nil) {
        self.watcherButton.frame = self.inView.bounds;
        [self.inView addSubview:self.watcherButton];
    }
    else {
        self.watcherButton.frame = CGRectMake(0, 64, w, f);
        UIView* view = [self topSuperView];
        if (view!=nil)
        [view addSubview:self.watcherButton];
    }
    if ( self.delegate != nil ) {
        if ( [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
            [self.delegate searchBarTextDidBeginEditing:self];
        }
    }
}

- (void)keyboardWillHide:(NSNotification*)noti
{
    [self.watcherButton removeFromSuperview];
}

- (void)setShowCancelButton:(BOOL)showCancelButton
{
    [self.searchBar setShowsCancelButton:showCancelButton animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if (self.delegate!=nil) {
        if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
            [self.delegate searchBarCancelButtonClicked:self];
            return;
        }
    }
    [self.searchBar resignFirstResponder];
}


- (void)watcherButtonTouchup:(MiniUIButton*)button
{
    [self.watcherButton removeFromSuperview];
    [self.searchBar resignFirstResponder];
}


- (void)setPlaceholder:(NSString*)placeholder
{
    self.searchBar.placeholder = placeholder;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (self.showCancelButtonWhenEdit) {
        self.showCancelButton = YES;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.showCancelButtonWhenEdit) {
        self.showCancelButton = NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    if ( self.delegate != nil ) {
        if ( [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
            [self.delegate searchBarSearchButtonClicked:self];
    }
}

- (BOOL)endEditing:(BOOL)animated
{
    return [self.searchBar endEditing:animated];
}

- (void)setText:(NSString *)text
{
    self.searchBar.text = text;
}

- (NSString*)text
{
    return self.searchBar.text;
}

@end