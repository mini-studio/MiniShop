//
//  MSImportFavViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-9.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopGroupListViewController.h"
#import "MSShopInfo.h"
#import "EGOUITableView.h"
#import "UILabel+Mini.h"
#import "UIColor+Mini.h"
#import "MSShopInfoCell.h"
#import "MSUIWebViewController.h"
#import "MSShopGalleryViewController.h"
#import "MSUISearchBar.h"

@interface MSShopGroupListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic,strong) NSDictionary *dataSource;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) UISearchDisplayController *searchController;
@property (nonatomic) BOOL inited;
@end

@interface MSShopGroupListViewController (search)
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
- (UISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder;
- (void)search:(NSString *)key;
@end

@implementation MSShopGroupListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.inited = NO;
    }
    return self;
}

- (void)setBackGroudImage:(NSString *)imageName
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createTableView];
    [self setNaviBackButton];
    if ( self.type == EImportFav )
    {
        self.navigationItem.title = @"导入收藏夹";
        if ( self.favData != nil )
        {
            [self loadFavData];
        }
    }
    else if ( self.type == ESearch || self.type == ESearchInCategory )
    {
        self.navigationItem.title = @"搜索";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( self.type == ESearch && !self.inited )
    {
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    if ( self.type == ESearchInCategory && self.key.length > 0 && !self.inited)
    {
        [self search:self.key];
    }
    self.inited = YES;
}

- (void)createTableView
{
    self.tableView = [self createPlainTableView];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    [self.view addSubview:self.tableView];
    if ( self.type == ESearch )
    {
        [self createSearchBar:self placeHolder:@""];
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)dataSourceAtSection:(NSInteger)section
{
    NSArray *ds = [self.dataSource valueForKey:section==0?@"record":@"norecord"];
    return ds;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) return @"已经收录的商家";
    else return @"未收录的商家";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *ds = [self dataSourceAtSection:section];
    if ( ds.count > 0 ) return 30;
    else return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"web_toolbar_bg_"]];
    view.backgroundColor = bgColor;
    UILabel *label = [UILabel LabelWithFrame:CGRectMake(5, 0, view.width-10, 30) bgColor:bgColor text:[self titleForHeaderInSection:section] color:[UIColor colorWithRGBA:0x785530ff] font:[UIFont boldSystemFontOfSize:16] alignment:NSTextAlignmentLeft shadowColor:nil shadowSize:CGSizeZero];
    label.centerY = view.height/2 + 5;
    [view addSubview:label];
    MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"这是什么>>" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRGBA:0x785530ff] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRGBA:0xffffffff] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.height= view.height;
    button.titleLabel.height = view.height;
    [button sizeToFit];
    button.frame = CGRectMake(view.width - button.width - 10, (view.height-button.height)/2 + 5, button.width, button.height);
    [view addSubview:button];
    __weak typeof (self) pSelf = self;
    [button setTouchupHandler:^(MiniUIButton *button) {
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:@"http://youjiaxiaodian.com/api/help" title:@"" toolbar:NO];
        [pSelf.navigationController pushViewController:controller animated:YES];
    }];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *ds = [self dataSourceAtSection:section];
    return ds.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSShopInfo *info = [ds objectAtIndex:indexPath.row];
    if ( info.shop_id > 0 ) {
        MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
        controller.shopInfo = info;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [self actionGoToShopping:info];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSShopInfo *info = [ds objectAtIndex:indexPath.row];
    return [MSShopInfoCell height:info];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [cell.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRGBA:0xefefefff];
    }
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSShopInfo *info = [ds objectAtIndex:indexPath.row];
    cell.shopInfo = info;
    cell.button.userInfo = info;
    return cell;
}

- (void)loadFavData
{
    id list = [self.favData valueForKey:@"resultList"];
    if ( [list isKindOfClass:[NSArray class]])
    {
        [self showWating:nil];
        __weak typeof (self) pSelf = self;
        [[ClientAgent sharedInstance] shopsInfo:list userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil )
            {
                pSelf.dataSource = data;
                [pSelf.tableView reloadData];
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    }
    else
    {
        [self showMessageInfo:@"发生错误啦" delay:2];
    }
}

- (void)buttonTap:(__weak MiniUIButton *)button
{
    __PSELF__;
    [self userAuth:^{
        MSShopInfo *info = button.userInfo;
        if ( info.shop_id == 0 ) // 收录
        {
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] usercooperate:info userInfo:nil block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if ( error == nil )
                {
                    info.shop_id = -100;
                    [UIView animateWithDuration:0.25 animations:^{
                        button.alpha = 0.2;
                    }completion:^(BOOL finished) {
                        button.hidden = YES;
                    }];
                }
                else
                {
                    [pSelf showErrorMessage:error];
                }
            }];
        }
        else // 关注
        {
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] like:@"shop" action:info.like?@"off":@"on" mid:info.shop_id block:^(NSError *error,  MSObject* data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if ( error == nil )
                {
                    info.like = !info.like;
                    [MSShopInfoCell resetButtonState:button shopInfo:info];
                }
                else
                {
                    [pSelf showErrorMessage:error];
                }
            }];
        }
    }];
}
@end


@implementation  MSShopGroupListViewController (search)

- (UISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    MSUISearchBar *searchBar = [[MSUISearchBar  alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = placeHolder;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = (id<UITableViewDelegate>) self;
    self.searchController.searchResultsDataSource = (id<UITableViewDataSource>)self;
    self.searchController.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    [self configureSearchBar:searchBar];
    return searchBar;
}

- (void)configureSearchBar:(MSUISearchBar *)searchBar
{
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ( self.searchDisplayController.isActive)
    {
        NSString  *key = searchBar.text;
        if ( key.length > 0 )
        {
            [self search:key];
        }
        [self.searchDisplayController setActive:NO animated:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchDisplayController setActive:NO animated:NO];
    [self back];
}

- (void)search:(NSString *)key
{
    [self showWating:nil];
    __weak typeof (self)pSelf = self;
    [[ClientAgent sharedInstance] searchshop:key first:self.key userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            pSelf.dataSource = data;
            [pSelf.tableView reloadData];
        }
        else
        {
            [pSelf showErrorMessage:error];
        }
    }];
}
@end
