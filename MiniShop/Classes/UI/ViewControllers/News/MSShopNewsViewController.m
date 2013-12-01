//
//  MSShopNewsViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopNewsViewController.h"
#import "MiniUISegmentView.h"

@interface MSShopNewsViewController ()

@end

@implementation MSShopNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.mark = NO;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setNaviBackButton];
    self.naviTitleView.title = @"好友关注的店铺";
}

- (void)setNaviButtons
{
    
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

- (void)loadNews:(int)page
{
    __weak typeof (self) pSelf = self;
    [[ClientAgent sharedInstance] shopnews12:self.shopIds page:page userInfo:[NSNumber numberWithInt:0]
                                     block:^(NSError *error, id data, id userInfo, BOOL cache) {
                                         [pSelf dismissWating];
                                         if ( error == nil )
                                         {
                                             [pSelf receiveData:data page:page type:0];
                                         }
                                         else
                                         {
                                             [pSelf showErrorMessage:error];
                                         }
                                     }];
}

@end
