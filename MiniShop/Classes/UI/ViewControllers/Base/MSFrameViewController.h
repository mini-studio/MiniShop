//
//  MSFrameViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSTopTitleView.h"

@interface MSFrameViewController : MSViewController
@property (nonatomic,strong)NSMutableArray *subControllers;
@property (nonatomic,strong)UIScrollView *containerView;
@property (nonatomic,strong)MSTopTitleView *topTitleView;
@end
