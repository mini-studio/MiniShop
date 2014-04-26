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
#import "MSNTransformButton.h"
#import "MSNSearchShopTitleView.h"
#import "MSNShopDetailViewController.h"
#import "MSNCate.h"
#import "MiniUIWebViewController.h"
#import "MSNSearchShopHelpViewController.h"

@interface MSNSearchShopViewController ()<MSNUISearchBarDelegate,MSNShopInfoCellDelegate,MSTransformButtonDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic,strong)MSNSearchShopTitleView *searchTitleView;
@property (nonatomic)int page;
//空为按相关度(默认), like关注度, grade信用, sale总售出件数
@property (nonatomic,strong)NSString *orderBy;
@end

@implementation MSNSearchShopViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.orderBy = @"";
        self.key = @"";
        self.cate = nil;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    if (self.cate!=nil) {
        self.searchBar = [self createSearchBar:self placeHolder:[NSString stringWithFormat:@"搜%@店",self.cate.title]];
    }
    else {
        self.searchBar = [self createSearchBar:self placeHolder:@"搜店"];
    }
    [self setNaviRightButtonImage:@"contact_info" highlighted:@"contact_info_hover" target:self action:@selector(actionRightButtonTap)];
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
    searchBar.showCancelButtonWhenEdit = NO;
    [self.naviTitleView addSubview:searchBar];
    return searchBar;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.key.length>0 || self.cate!=nil){
       [self.tableView triggerRefresh];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataSource.info.count>0){
        [self.tableView reloadData];
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


- (BOOL)showSearchTitleView
{
    return self.cate == nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self showSearchTitleView]?28:0);
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self showSearchTitleView]) {
        if (_searchTitleView==nil){
            _searchTitleView=[[MSNSearchShopTitleView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 28)];;
            _searchTitleView.backgroundColor = [self backgroundColor];
            _searchTitleView.transformButton.delegate = self;
            _searchTitleView.transformButton.items = @[@"按相关度排序",@"按关注度排序",@"按信用度排序",@"按总售数排序"];
        }
        _searchTitleView.keyWord = _dataSource.info_message;
        return _searchTitleView;
    }
    else {
        return nil;
    }
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
    controller.key = self.key;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar
{
    self.key = searchBar.text;
    [self showWating:nil];
    [self search:1 delay:0];
}

- (void)receiveData:(MSNShopList *)data page:(int)page
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

- (void)actionRightButtonTap
{
    MSNSearchShopHelpViewController *controller = [[MSNSearchShopHelpViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)search:(int)page delay:(CGFloat)delay
{
    __PSELF__;
    [[ClientAgent sharedInstance] searchshop:_key sort:self.orderBy page:page tag_id:self.cate == nil? 0 : [self.cate
            .param integerValue]       block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error == nil) {
            [pSelf receiveData:data page:page];
        }
    }];
}

- (void)favShop:(MSNShopInfo*)shopInfo
{
    shopInfo.user_like = 1;
    NSInteger index = [self.dataSource.info indexOfObject:shopInfo];
    if (index!=NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView reloadData];
    }
    __PSELF__;
    
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        //[pSelf dismissWating];
        if (error==nil) {
            shopInfo.user_like = 1;
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)cancelFavShop:(MSNShopInfo*)shopInfo
{
    shopInfo.user_like = 0;
    NSInteger index = [self.dataSource.info indexOfObject:shopInfo];
    if (index!=NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView reloadData];
    }
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"off" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        //[pSelf dismissWating];
        if (error==nil) {
            shopInfo.user_like = 0;
            [pSelf.tableView reloadData];
        }
        else {
            [self showErrorMessage:error];
        }
    }];
}

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    if (button.selectedIndex==0) {
        self.orderBy = @"";
    }
    else if (button.selectedIndex==1) {
        self.orderBy = @"like";
    }
    else if (button.selectedIndex==2) {
        self.orderBy = @"grade";
    }
    else if (button.selectedIndex==3) {
        self.orderBy = @"sale";
    }
    [self search:1 delay:0];
}

@end
