//
//  MSNShopDetailViewController.m
//  MiniShop
//  店铺详情页
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopDetailViewController.h"
#import "MSNShopInfoView.h"

@interface MSNShopDetailViewController ()
@property (nonatomic,strong)MSNShopInfoView *shopInfoView;
@end

@implementation MSNShopDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.showNaviView = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	[self setNaviBackButton];
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 60)];
    [self.contentView addSubview:self.shopInfoView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.naviTitleView setTitle:self.shopInfo.shop_title];
    [self.shopInfoView setShopInfo:self.shopInfo];
    [self loadData:1 delay:0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    [[ClientAgent sharedInstance] shopgoods:self.shopInfo.shop_id tagId:@"" sort:@"time" key:@"" page:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
        
    }];
}

@end
