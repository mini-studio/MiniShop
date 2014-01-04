//
//  CreditableIndexViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "CreditableIndexViewController.h"
#import "MSNSearchShopViewController.h"
#import "MSNUISearchBar.h"
#import "ClientAgent+Mini.h"
#import "MSNCate.h"
#import "MSNWellCateCell.h"

@interface MSNCreditableHeaderView : UITableViewHeaderFooterView
@end

@implementation MSNCreditableHeaderView
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textAlignment = UITextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:12];
}
@end

@interface CreditableIndexViewController ()<MSNUISearchBarDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
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
    }
    MSNWellCateGroup *group = [self.dataSource.info objectAtIndex:indexPath.section];
    cell.group = group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
