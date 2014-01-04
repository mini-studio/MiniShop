//
//  MSNUISearchBar.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNUISearchBar.h"

@interface MSNUISearchBar()<UISearchBarDelegate>
@property (nonatomic,strong)MiniUIButton *searchButton;
@property (nonatomic,strong)UISearchBar *searchBar;

@end

@implementation MSNUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        CGRect frame = self.bounds;
        frame.size = CGSizeMake(self.width, self.height);
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor clearColor];
        [self addSubview:self.searchBar];
        self.searchButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.searchButton.backgroundColor = self.backgroundColor;
        [self.searchButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
        self.searchButton.frame = CGRectMake(self.width, 10, 50, self.height-20);
        [self.searchButton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)setShowCancelButton:(BOOL)showCancelButton
{
    CGRect frame = self.bounds;
    CGFloat btnLeft = self.width;
    _showCancelButton = showCancelButton;
    if ( !_showCancelButton ) {
        [self.searchButton removeFromSuperview];
    }
    else {
        [self addSubview:self.searchButton];
        frame.size = CGSizeMake(self.width - 50, self.height);
        btnLeft = self.width - 50;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.searchBar.frame = frame;
        self.searchButton.left = btnLeft;
    }];
}

- (void)setAlwaysShowCancelButton:(BOOL)alwaysShowCancelButton
{
    _alwaysShowCancelButton = alwaysShowCancelButton;
    self.showCancelButton = alwaysShowCancelButton;
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


@interface MSNSearchView()<UITextFieldDelegate>
@property (nonatomic,strong)MiniUIButton *cancelButton;
@property (nonatomic,strong)UITextField  *searchBar;
@end

@implementation MSNSearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.backgroundColor = [UIColor redColor];
    CGRect rect = CGRectInset(self.bounds, 50, 5);
    self.searchBar = [[UITextField alloc] initWithFrame:rect];
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
}

- (void)actionCancel
{
    [self hide];
    if ( self.delegate != nil ) {
        if ( [self.delegate respondsToSelector:@selector(searchViewCancelButtonClicked:)]) {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate searchViewCancelButtonClicked:self];
            });
        }
    }
}

- (void)show
{
    [UIView animateWithDuration:0.25 animations:^{
        self.top = 0;
    } completion:^(BOOL finished) {
        [self.searchBar becomeFirstResponder];
    }];
}

- (void)hide
{
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.bottom = 0;
    }];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@"\n"] ) {
        [self hide];
         if ( [self.delegate respondsToSelector:@selector(searchViewSearchButtonClicked:)]) {
            if ( self.delegate != nil ) {
                double delayInSeconds = 0.5;
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
@end
