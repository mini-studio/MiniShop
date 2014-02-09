//
//  MSNShopListViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-2-9.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopListViewController.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "EGOUITableView.h"
#import "MSUIMoreDataCell.h"
#import "UIColor+Mini.h"
#import "MSNShopDetailViewController.h"

@interface MSNShopListViewController () <MSNShopInfoCellDelegate>
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic) int page;
@end

@implementation MSNShopListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	[self setNaviBackButton];
    self.naviTitleView.title = self.ctitle;
    [self createTableView];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadFavShopListData:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)backgroundColor
{
    return [UIColor colorWithRGBA:0xfaf1f2ff];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.info.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSNShopInfo *info = [self.dataSource.info objectAtIndex:indexPath.row];
    return [MSNShopInfoCell height:info];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSNShopInfo *info = [self.dataSource.info objectAtIndex:indexPath.row];
    MSNShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSNShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.shopInfoDelegate = self;
        cell.backgroundColor = [self backgroundColor];
    }
    cell.shopInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
    controller.shopInfo = [self.dataSource.info objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)recevieData:(MSNShopList*)data page:(int)page
{
    _page = page;
    if ( page == 1) {
        [self.tableView refreshDone];
        self.dataSource = data;
    }
    else {
        [self.dataSource append:data];
    }
    [self.tableView reloadData];
    [self setMoreDataAction:(data.next_page==1) tableView:self.tableView];
    [self.tableView reloadData];
    LOG_DEBUG(@"%@",[data description]);
}

- (void)loadMore
{
    [self loadFavShopListData:(_page+1)];
}

- (void)loadFavShopListData:(int)page
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] myshoplist:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
         [pSelf dismissWating];
        if (error==nil) {
            [pSelf recevieData:data page:page];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)favShop:(MSNShopInfo*)shopInfo
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            shopInfo.like = 1;
            [pSelf.tableView reloadData];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)cancelFavShop:(MSNShopInfo*)shopInfo
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"off" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            shopInfo.like = 0;
            [pSelf.tableView reloadData];
        }
        else {
            [self showErrorMessage:error];
        }
    }];
}


@end
