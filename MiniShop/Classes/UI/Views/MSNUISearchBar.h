//
//  MSNUISearchBar.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSNUISearchBar;

@protocol MSNUISearchBarDelegate <NSObject>
@optional
- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(MSNUISearchBar *)searchBar;
@end

@interface MSNUISearchBar : UIView
@property (nonatomic,assign)id<MSNUISearchBarDelegate> delegate;
@property (nonatomic,strong)NSString *placeholder;
@property (nonatomic,strong)NSString *text;
@property (nonatomic)BOOL showCancelButtonWhenEdit;
@end

