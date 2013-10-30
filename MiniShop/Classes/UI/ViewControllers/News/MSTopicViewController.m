//
//  MSTopicViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-16.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSTopicViewController.h"
#import "MiniUISegmentView.h"

@interface MSTopicViewController ()

@end

@implementation MSTopicViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.mark = NO;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.titleView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"全站上新";
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.segment.selectedSegmentIndex = 1;
    });
}

- (void)setNaviButtons
{
    if ( self.navigationController.viewControllers.count > 0  && self.navigationController.viewControllers[0]!=self) {
        [self setNaviBackButton];
    }
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    self.segment.selectedSegmentIndex = 1;
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataSourceForType:(int)type
{
    return self.dataSource;
}

- (void)initData
{
}

@end
