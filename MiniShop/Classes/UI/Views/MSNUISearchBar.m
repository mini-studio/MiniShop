//
//  MSNUISearchBar.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNUISearchBar.h"
#import "MSTransformButton.h"
#import "UIColor+Mini.h"

@interface MSNUISearchBar()<UISearchBarDelegate>
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)MiniUIButton *watcherButton;

@end

@implementation MSNUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = NAVI_BG_COLOR;
        CGRect frame = self.bounds;
        frame.size = CGSizeMake(self.width, self.height);
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor clearColor];
        [self addSubview:self.searchBar];
        self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = self.backgroundColor;
        [self.button setTitle:@"取消" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont systemFontOfSize:16];
        self.button.frame = CGRectMake(self.width, 10, 50, self.height-20);
        [self.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)keyboardWillShow:(NSNotification*)noti
{
    CGFloat f = [UIScreen mainScreen].bounds.size.height-64;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    self.watcherButton.frame = CGRectMake(0, 64, w, f);
    [WINDOW addSubview:self.watcherButton];
}

- (void)keyboardWillHide:(NSNotification*)noti
{
    [self.watcherButton removeFromSuperview];
}

- (void)setShowCancelButton:(BOOL)showCancelButton
{
    if (self.button==nil) {
        return;
    }
    CGRect frame = self.bounds;
    CGFloat btnLeft = self.width;
    _showCancelButton = showCancelButton;
    if ( !_showCancelButton ) {
        [self.button removeFromSuperview];
    }
    else {
        [self addSubview:self.button];
        frame.size = CGSizeMake(self.width - 50, self.height);
        btnLeft = self.width - 50;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.searchBar.frame = frame;
        self.button.left = btnLeft;
    }];
}

- (void)setAlwaysShowCancelButton:(BOOL)alwaysShowCancelButton
{
    _alwaysShowCancelButton = alwaysShowCancelButton;
    self.showCancelButton = alwaysShowCancelButton;
}

- (void)watcherButtonTouchup:(MiniUIButton*)button
{
    [self.watcherButton removeFromSuperview];
    [self.searchBar resignFirstResponder];
}


- (void)buttonTap:(MiniUIButton*)button
{
    [self.searchBar resignFirstResponder];
    if ( self.delegate != nil ) {
        if ( [self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void)setPlaceholder:(NSString*)placeholder
{
    self.searchBar.placeholder = placeholder;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ( !_alwaysShowCancelButton )
    {
        if ( !_showCancelButton ) {
        self.showCancelButton = YES;
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ( !_alwaysShowCancelButton )
    {
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

- (void)setText:(NSString *)text
{
    self.searchBar.text = text;
}

- (NSString*)text
{
    return self.searchBar.text;
}

@end


@interface MSNSearchView()<UITextFieldDelegate,MSTransformButtonDelegate>
@property (nonatomic,strong)MiniUIButton *cancelButton;
@property (nonatomic,strong)UITextField  *searchBar;
@property (nonatomic,strong)MSTransformButton *transformButton;
@end

@implementation MSNSearchView
@synthesize scopeIndex = _scopeIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = NAVI_BG_COLOR;
        _floatting = YES;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    CGRect rect = CGRectInset(self.bounds, 50, 5);
    self.searchBar = [[UITextField alloc] initWithFrame:rect];
    self.searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchBar.font = [UIFont systemFontOfSize:14];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.searchBar];
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.delegate = self;
    
    self.cancelButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(self.width-45, (self.height-40)/2, 40,40);
    [self addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(actionCancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(0, 0, 80, self.searchBar.height)];
    self.transformButton.fontColor = NAVI_BG_COLOR;
    self.transformButton.fontSize = 14;
    self.transformButton.delegate = self;
    self.searchBar.leftViewMode = UITextFieldViewModeAlways;
    self.searchBar.leftView = self.transformButton;
}

- (void)setScopeString:(NSArray *)scopeString
{
    _scopeString = scopeString;
    self.transformButton.items = scopeString;
}

- (void)setScopeString:(NSArray *)scopeString defaultIndex:(int)index
{
    _scopeString = scopeString;
    _scopeIndex = index;
    [self.transformButton setItems:scopeString defaultIndex:index];
}

- (void)setScopeIndex:(NSInteger)scopeIndex
{
    _scopeIndex = scopeIndex;
    self.transformButton.selectedIndex = scopeIndex;
}

- (NSInteger)scopeIndex
{
    return _scopeIndex;
}

- (void)actionCancel
{
    [self hide];
    if ( self.delegate != nil ) {
        if ( [self.delegate respondsToSelector:@selector(searchViewCancelButtonClicked:)]) {
            double delayInSeconds = 0.01;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate searchViewCancelButtonClicked:self];
            });
        }
    }
}

- (void)show
{
    if ( _floatting ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.top = 0;
        } completion:^(BOOL finished) {
            [self.searchBar becomeFirstResponder];
        }];
    }
}

- (void)hide
{
    if (_floatting) {
        [self.searchBar resignFirstResponder];
        [UIView animateWithDuration:0.25 animations:^{
            self.bottom = 0;
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@"\n"] ) {
        [self hide];
         if ( [self.delegate respondsToSelector:@selector(searchViewSearchButtonClicked:)]) {
            if ( self.delegate != nil ) {
                double delayInSeconds = 0.01;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.delegate searchViewSearchButtonClicked:self];
                });
            }
         }
        return NO;
    }
    return YES;
}

- (NSString*)text
{
    return self.searchBar.text;
}

- (void)setText:(NSString *)text
{
    self.searchBar.text = text;
}

- (void)transformButtonValueChanged:(MSTransformButton*)button
{
    _scopeIndex = button.selectedIndex;
    if (self.delegate)
        if ([self.delegate respondsToSelector:@selector(searchViewScopeValueChanged:)])
            [self.delegate searchViewScopeValueChanged:self];
}

@end
