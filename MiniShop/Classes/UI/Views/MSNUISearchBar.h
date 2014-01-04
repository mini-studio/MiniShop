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
- (void)searchBarCancelButtonClicked:(MSNUISearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar;

@end

@interface MSNUISearchBar : UIView
@property (nonatomic,assign)id<MSNUISearchBarDelegate> delegate;
@property (nonatomic,strong)NSString *placeholder;
@property (nonatomic,strong)NSString *text;
@property (nonatomic)BOOL showCancelButton;
@property (nonatomic)BOOL alwaysShowCancelButton;
@end

@class MSNSearchView;
@protocol MSNSearchViewDelegate <NSObject>

@optional
- (void)searchViewCancelButtonClicked:(MSNSearchView *)searchBar;
- (void)searchViewSearchButtonClicked:(MSNSearchView *)searchBar;
- (void)searchViewScopeValueChanged:(MSNSearchView *)searchBar;
@end

@interface MSNSearchView : UIView
@property (nonatomic,assign)id<MSNSearchViewDelegate> delegate;
@property (nonatomic)BOOL floatting;
@property (nonatomic,strong)NSString *text;
@property (nonatomic,strong)NSArray *scopeString;
@property (nonatomic)NSInteger scopeIndex;
- (void)show;
- (void)hide;

- (void)setScopeString:(NSArray *)scopeString defaultIndex:(int)index;
@end
