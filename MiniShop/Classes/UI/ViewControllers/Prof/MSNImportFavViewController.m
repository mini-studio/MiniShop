//
//  MSImportFavViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-9.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNImportFavViewController.h"
#import "MSFShopInfo.h"
#import "UILabel+Mini.h"
#import "UIColor+Mini.h"
#import "MSUIWebViewController.h"
#import "MSShopInfoCell.h"
#import "MSNShop.h"
#import "MSNShopDetailViewController.h"

@interface MSNImportFavViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@end


@implementation MSNImportFavViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  @"导入收藏夹";
}

- (void)createTableView
{
    self.tableView = [self createEGOTableView];
    [self.contentView addSubview:self.tableView];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf loadFavShopListData:1];
    }];
}

- (void)createNaviRightButton
{

}

- (void)loadFavShopListData:(int)page
{
    __PSELF__;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ClientAgent sharedInstance] importFav:self userInfo:nil block:^(NSError *error, id data, id userInfo,
                                                                          BOOL cache) {
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