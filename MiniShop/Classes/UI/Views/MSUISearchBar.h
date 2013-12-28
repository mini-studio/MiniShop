//
//  MSUISearchBar.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSUISearchBar;

@protocol MSUISearchBarDelegate <NSObject>

@optional
- (void)searchBarCancelButtonClicked:(MSUISearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(MSUISearchBar *)searchBar;

@end

@interface MSUISearchBar : UIView
@property (nonatomic,assign)id<MSUISearchBarDelegate> delegate;
@property (nonatomic,strong)NSString *placeholder;
@property (nonatomic,strong)NSString *text;
@property (nonatomic)BOOL showCancelButton;
@property (nonatomic)BOOL alwaysShowCancelButton;
@end
