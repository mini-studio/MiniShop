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
#import "RTLabel.h"
#import "MSNTransformButton.h"
#import "MSNSearchShopTitleView.h"
#import "MSNShopDetailViewController.h"

@interface MSNSearchShopViewController ()<MSNUISearchBarDelegate,MSNShopInfoCellDelegate,MSTransformButtonDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic,strong)MSNSearchShopTitleView *searchTitleView;
@property (nonatomic)int page;
//空为按相关度(默认), like关注度, grade信用, sale总售出件数
@property (nonatomic,strong)NSString *orderby;
@end

@implementation MSNSearchShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.orderby = @"";
        self.key = @"";
        self.tagId = 0;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    if (self.cTitle.length>0) {
        [self.naviTitleView setTitle:self.cTitle];
    }
    else {
        self.searchBar = [self createSearchBar:self placeHolder:@"搜店"];
        [self setNaviRightButtonImage:@"contact_info" highlighted:@"contact_info_hover" target:self action:@selector(actionRightButtonTap)];
        self.naviTitleView.leftButton.left = 10;
    }
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
    if (self.key.length>0 || self.tagId>0){
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


- (BOOL)showSearchTitleView
{
    return self.cTitle.length==0;
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
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar
{
    self.key = searchBar.text;
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
    [self showMessageInfo:@"wating for implemention..." delay:2];
}


- (void)search:(int)page delay:(CGFloat)delay
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] searchshop:_key sort:self.orderby page:page tag_id:self.tagId block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            [pSelf receiveData:data page:page];
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
            shopInfo.user_like = 1;
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
        self.orderby = @"";
    }
    else if (button.selectedIndex==1) {
        self.orderby = @"like";
    }
    else if (button.selectedIndex==2) {
        self.orderby = @"grade";
    }
    else if (button.selectedIndex==3) {
        self.orderby = @"sale";
    }
    [self search:1 delay:0];
}

@end
