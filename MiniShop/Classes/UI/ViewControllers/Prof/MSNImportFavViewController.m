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

- (void)loadFavShopListData:(int)page
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] importFav:self userInfo:nil block:^(NSError *error, id data, id userInfo,
            BOOL cache) {
        if (error==nil) {
            if([data isKindOfClass:[MSNShopList class]]) {
                [pSelf receiveData:data page:page];
            }
            else {
                id list = [data valueForKey:@"resultList"];
                if ( [list isKindOfClass:[NSArray class]]) {
                    [pSelf showWating:nil];
                    [[ClientAgent sharedInstance] importShopInfo:list co:nil userInfo:nil block:^(NSError *error, id data,
                            id userInfo, BOOL cache) {
                        [pSelf dismissWating];
                        if (error==nil) {
                            [pSelf receiveData:data page:page];
                        }
                        else {
                            [pSelf showErrorMessage:error];
                        }
                    }];
                }
                else {
                    [pSelf showMessageInfo:@"发生错误啦" delay:2];
                }
            }
        }
        else {
           [pSelf dismissWating];
           [pSelf showErrorMessage:error];
        }
    }];
}
@end