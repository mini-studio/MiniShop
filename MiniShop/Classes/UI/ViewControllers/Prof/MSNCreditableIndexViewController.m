//
//  MSNCreditableIndexViewController.m
//  MiniShop 好店汇
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNCreditableIndexViewController.h"
#import "MSNSearchShopViewController.h"
#import "MSNUISearchBar.h"
#import "MSNCate.h"
#import "MSNWellCateCell.h"
#import "MSUIWebViewController.h"
#import "MSNShopListViewController.h"
#import "MSNShopDetailViewController.h"

@interface MSNCreditableHeaderView : UITableViewHeaderFooterView
@property (nonatomic,strong)UIView *leftview;
@end

@implementation MSNCreditableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, self.height)];
        self.leftview.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.leftview];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.leftview.height = self.height;
    self.textLabel.left = 10;
    self.textLabel.centerY = self.height/2;
    self.tintColor = [UIColor clearColor];
    self.backgroundView = nil;
}
@end

@interface MSNCreditableIndexViewController ()<MSNUISearchBarDelegate,MSNWellCateCellDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
@property (nonatomic,strong)NSString *key;
@property (nonatomic,strong)MSNWellCateList *dataSource;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation MSNCreditableIndexViewController

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
    self.searchBar = [self createSearchBar:self placeHolder:@"搜店"];
    self.tableView = [self createPlainTableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:self.tableView];
    [self.tableView registerClass:[MSNCreditableHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (MSNUISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    MSNUISearchBar *searchBar = [[MSNUISearchBar  alloc] initWithFrame:self.naviTitleView.bounds];
    searchBar.delegate = self;
    searchBar.placeholder = placeHolder;
    [self.naviTitleView addSubview:searchBar];
    return searchBar;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.info.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 1;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>0 && indexPath.row==0) {
        return 20;
    }
    else {
        MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
        return [MSNWellCateCell heightForGroup:group];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>0 && indexPath.row==0) {
        NSString *identifier = @"cell-header";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.backgroundView = nil;
            cell.backgroundColor = [UIColor clearColor];
            MSNCreditableHeaderView *view = [[MSNCreditableHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 20)];
            view.tag = 100;
            [cell addSubview:view];
        }
        MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
        MSNCreditableHeaderView *view = (MSNCreditableHeaderView*)[cell viewWithTag:100];
        view.textLabel.text = group.title;
        return cell;
    }
    else {
        NSString *identifier = @"cell";
        MSNWellCateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil ) {
            cell = [[MSNWellCateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.wellCateCellDelegate = self;
        }
        MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
        cell.group = group;
        return cell;
    }
}

- (void)handleTouchInfo:(MSNWellCate *)cate
{
    if ([cate.param isEqualToString:@"-100"]) { //我的商城
        MSNShopListViewController *controller = [[MSNShopListViewController alloc] init];
        controller.cTitle = @"我的商城";
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([cate.param isEqualToString:@"-99"]){//猜你喜欢
        MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
        controller.random = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([cate.param isEqualToString:@"-98"]){//下单有礼
        
    }
    else {
        if ([cate.type isEqualToString:@"web_url"]) {
            MSUIWebViewController *controller = [[MSUIWebViewController alloc] init];
            controller.uri = cate.param;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            MSNSearchShopViewController *controller = [[MSNSearchShopViewController alloc] init];
            controller.cate = cate;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar
{
    NSString  *key = searchBar.text;
    MSNSearchShopViewController *controller = [[MSNSearchShopViewController alloc] init];
    controller.key = key;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] catelist:^(NSError *error, MSNWellCateList* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error ==nil ) {
            pSelf.dataSource = data;
            [pSelf.tableView reloadData];
        }
    }];
}


@end
