//
//  MSFrameViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSNaviMenuView.h"

@interface MSFrameViewController : MSViewController
@property (nonatomic,strong)NSMutableArray *subControllers;
@property (nonatomic,strong)UIScrollView *containerView;
@property (nonatomic,strong)MSNaviMenuView *topTitleView;
@property (nonatomic,readonly)MSViewController *currentController;

- (void)clearSubControllers;
@end
