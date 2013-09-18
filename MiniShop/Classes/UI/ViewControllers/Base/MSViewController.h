//
//  MSViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniViewController.h"
@class SVPullToRefresh;
@class MSShopInfo;

@interface MSViewController : MiniViewController
- (void)setBackGroudImage:(NSString *)imageName;
- (void)setViewBackgroundColor;
- (void)addRightRefreshButtonToTarget:(id)target action:(SEL)action;
- (void)setNaviLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action;
- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (UITableView *)createPlainTableView;
- (UITableView*)createGroupedTableView;

- (void)setPullToRefreshViewStyle:(SVPullToRefresh*)view;

- (void)actionGoToShopping:(MSShopInfo *)info;

- (BOOL)isLoading;

- (void)showErrorMessage:(NSError *)error;

- (void)remindLogin;

- (void)userAuth:(void (^)())block;

- (void)setDefaultNaviBackground;

@end
