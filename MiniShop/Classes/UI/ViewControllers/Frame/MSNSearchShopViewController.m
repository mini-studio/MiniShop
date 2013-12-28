//
//  MSNSearchShopViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNSearchShopViewController.h"
#import "MSUISearchBar.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "EGOUITableView.h"
#import "MSUIMoreDataCell.h"

@interface MSNSearchShopViewController ()<MSUISearchBarDelegate>
@property (nonatomic,strong)MSUISearchBar *searchBar;
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

- (MSUISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    CGRect frame = self.naviTitleView.bounds;
    frame = CGRectInset(frame, 44, 0);
    MSUISearchBar *searchBar = [[MSUISearchBar  alloc] initWithFrame:frame];
    searchBar.delegate = self;
    searchBar.placeholder = placeHolder;
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
        [cell.button addTarget:self action:@selector(actionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareShop:) forControlEvents:UIControlEventTouchUpInside];
        
    }
//    if ( self.type == EFollowed )
//    {
//        cell.showsShareButton = YES;
//        cell.shareButton.userInfo = info;
//    }
//    else
//    {
//        cell.showsShareButton = NO;
//    }
    cell.shopInfo = info;
    cell.button.userInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSNShopInfo *info = [self.dataSource.info objectAtIndex:indexPath.row];
//    if ( info.shop_id > 0 ) {
//        MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
//        controller.shopInfo = info;
//        [self.navigationController pushViewController:controller animated:YES];
//    }
//    else {
//        [self actionGoToShopping:info];
//    }
}

- (void)searchBarSearchButtonClicked:(MSUISearchBar *)searchBar
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

@end
