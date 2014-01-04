//
//  MSNSearchGoodsViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNSearchGoodsViewController.h"

@interface MSNSearchGoodsViewController ()

@end

@implementation MSNSearchGoodsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.showNaviView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = @"搜索";
    [self setNaviBackButton];
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    __PSELF__;
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showWating:nil];
        [[ClientAgent sharedInstance] searchgoods:_key type:@"1" sort:@"sale" page:1 block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if (error==nil) {
                [pSelf receiveData:data page:page];
            }
            else {
                [pSelf showErrorMessage:error];
            }
        }];

    });
}


@end
