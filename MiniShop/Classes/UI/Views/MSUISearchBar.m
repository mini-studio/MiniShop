//
//  MSUISearchBar.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUISearchBar.h"

@interface MSUISearchBar()<UISearchBarDelegate>
@property (nonatomic,strong)MiniUIButton *searchButton;
@property (nonatomic,strong)UISearchBar *searchBar;

@end

@implementation MSUISearchBar

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

- (NSString*)text
{
    return self.searchBar.text;
}

@end
