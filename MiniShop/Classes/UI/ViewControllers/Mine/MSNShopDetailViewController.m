//
//  MSNShopDetailViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopDetailViewController.h"

@interface MSNShopDetailViewController ()

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
