//
//  CreditableIndexViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "CreditableIndexViewController.h"
#import "MSUISearchBar.h"
#import "ClientAgent+Mini.h"
#import "MSNShopCate.h"
#import "MSNWellCateCell.h"

@interface CreditableIndexViewController ()<MSUISearchBarDelegate>
@property (nonatomic,strong)MSUISearchBar *searchBar;
@property (nonatomic,strong)NSString *key;
@property (nonatomic,strong)MSNWellCateList *dataSource;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation CreditableIndexViewController

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
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
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

- (MSUISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    MSUISearchBar *searchBar = [[MSUISearchBar  alloc] initWithFrame:self.naviTitleView.bounds];
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
    return 20;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.textAlignment = UITextAlignmentCenter;
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:section];
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
    }
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
    cell.group = group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)searchBarSearchButtonClicked:(MSUISearchBar *)searchBar
{
    NSString  *key = searchBar.text;
    if ( key.length > 0 ) {
        [self search:key];
    }
}

- (void)search:(NSString *)key
{
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
