//
//  MSNSearchShopViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNSearchShopViewController.h"
#import "MSNUISearchBar.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "EGOUITableView.h"
#import "MSUIMoreDataCell.h"
#import "UIColor+Mini.h"

@interface MSNSearchShopViewController ()<MSNUISearchBarDelegate,MSNShopInfoCellDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic)int page;
@end

@implementation MSNSearchShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.searchBar = [self createSearchBar:self placeHolder:@"搜店"];
    [self setNaviBackButton];
    self.naviTitleView.leftButton.left = 10;
    [self createTableView];
}

- (MSNUISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    CGRect frame = self.naviTitleView.bounds;
    frame = CGRectInset(frame, 44, 0);
    MSNUISearchBar *searchBar = [[MSNUISearchBar  alloc] initWithFrame:frame];
    searchBar.delegate = self;
    searchBar.placeholder = placeHolder;
    searchBar.button = nil;
    [self.naviTitleView addSubview:searchBar];
    return searchBar;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.key.length>0){
        self.searchBar.text = self.key;
        [self search:1 delay:0];
    }
}

- (void)createTableView
{
    self.tableView = [self createEGOTableView];
    [self.contentView addSubview:self.tableView];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf search:1 delay:0];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    cell.shopInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar
{
    self.key = searchBar.text;
    [self search:1 delay:0];
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
    [self search:(_page+1) delay:0.50f];
}


- (void)search:(int)page delay:(CGFloat)delay
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] searchshop:_key sort:@"" page:page tag_id:0 block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            [pSelf recevieData:data page:page];
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
            [self showErrorMessage:error];
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
