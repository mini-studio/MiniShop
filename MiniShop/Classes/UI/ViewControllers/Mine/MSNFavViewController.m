//
//  MSNFavViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNFavViewController.h"

@interface MSNFavViewController ()
@property (nonatomic) int page;
@end

@implementation MSNFavViewController

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
	self.naviTitleView.title = @"我的收藏";
    [self loadData:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMore
{
    [self loadData:(_page+1)];
}

- (void)receiveData:(id)data page:(int)page
{
    
}

- (void)loadData:(int)page
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] mygoodslist:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil ) {
            
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

@end
