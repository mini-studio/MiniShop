//
//  MSNSearchShopHelpViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-4-21.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNSearchShopHelpViewController.h"

@interface MSNSearchShopHelpViewController ()

@end

@implementation MSNSearchShopHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] searchhelp:^(NSError *error, NSString* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            self.content = data;
            self.title = @"搜索帮助";
            [_webView loadHTMLString:self.content baseURL:nil];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];

}
@end
