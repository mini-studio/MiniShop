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
#import "ClientAgent+Mini.h"
#import "MSNCate.h"
#import "MSNWellCateCell.h"
#import "MSUIWebViewController.h"
#import "MSNShopListViewController.h"

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
        self.textLabel.textAlignment = UITextAlignmentLeft;
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
    // Dispose of any resources that can be recreated.
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:section];
    return (group.title.length>0?20:0);
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:section];
    if (group.title.length == 0) {
        return nil;
    }
    MSNCreditableHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.text = group.title;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
    return [MSNWellCateCell heightForGroup:group];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSNWellCateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSNWellCateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.wellCateCellDelegate = self;
    }
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
    cell.group = group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)handleTouchInfo:(MSNWellCate *)cate
{
    if ([cate.param isEqualToString:@"-100"]) { //我的商城
        MSNShopListViewController *controller = [[MSNShopListViewController alloc] init];
        controller.ctitle = @"我的商城";
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([cate.param isEqualToString:@"-99"]){
        
    }
    else if ([cate.param isEqualToString:@"-98"]){
        
    }
    else {
        if ([cate.type isEqualToString:@"web_url"]) {
            MSUIWebViewController *controller = [[MSUIWebViewController alloc] init];
            controller.uri = cate.param;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            
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
