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
        frame.size = CGSizeMake(self.width - 50, self.height);
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor clearColor];
        [self addSubview:self.searchBar];
        self.searchButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.searchButton.backgroundColor = self.backgroundColor;
        [self.searchButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
        self.searchButton.frame = CGRectMake(self.width-50, 10, 50, self.height-20);
        [self addSubview:self.searchButton];
        [self.searchButton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}


- (void)buttonTap:(MiniUIButton*)button
{
    if ( self.delegate != nil ) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void)setPlaceholder:(NSString*)placeholder
{
    self.searchBar.placeholder = placeholder;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    if ( self.delegate != nil ) {
        [self.delegate searchBarSearchButtonClicked:self];
    }
}

- (NSString*)text
{
    return self.searchBar.text;
}

@end
