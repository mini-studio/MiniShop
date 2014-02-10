//
//  MSViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniViewController.h"
#import "EGOUITableView.h"
@class SVPullToRefresh;
@class MSShopInfo;

@interface MSViewController : MiniViewController
@property (nonatomic)BOOL showNaviView;

- (void)setBackGroudImage:(NSString *)imageName;
- (void)setViewBackgroundColor;
- (void)addRightRefreshButtonToTarget:(id)target action:(SEL)action;
- (void)setNaviLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action;
- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)setNaviRightButtonImage:(NSString *)imageName target:(id)target action:(SEL)action;
- (void)setNaviRightButtonImage:(NSString *)imageName highlighted:(NSString*)highlightedImage target:(id)target action:(SEL)action;

- (UITableView *)createPlainTableView;
- (UITableView*)createGroupedTableView;
- (EGOUITableView*)createEGOTableView;

- (void)setPullToRefreshViewStyle:(SVPullToRefresh*)view;

- (void)actionGoToShopping:(MSShopInfo *)info;

- (BOOL)isLoading;

- (void)showErrorMessage:(NSError *)error;

//- (void)userAuth:(void (^)())block;
//
//- (void)userAuthWithString:(NSString*)string block:(void (^)())block;

- (void)setDefaultNaviBackground;

- (void)setMoreDataAction:(BOOL)more tableView:(EGOUITableView*)tableView;

@end
