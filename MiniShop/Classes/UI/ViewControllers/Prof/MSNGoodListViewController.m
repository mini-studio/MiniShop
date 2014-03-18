//
//  MSNGoodListViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNGoodListViewController.h"
#import "MSNShopDetailViewController.h"
#import "MSNGoodsList.h"
#import "MSNGoodsTableCell.h"
#import "UIColor+Mini.h"

@interface MSNGoodListViewController ()

@end

@implementation MSNGoodListViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        _page = 1;
        self.showNaviView = NO;
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    [self createTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createTableView
{
    self.tableView = [self createEGOTableView];
    [self.contentView addSubview:self.tableView];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf loadData:1];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource.sort isEqualToString:SORT_TIME]) {
        return  2*[self.dataSource numberOfRows];
    }
    else {
        return [self.dataSource numberOfRows];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource.sort isEqualToString:SORT_TIME] && indexPath.row%2==0) {
        return  42;
    }
    else {
        int index = indexPath.row;
        if ([self.dataSource.sort isEqualToString:SORT_TIME]) {
            index/=2;
        }
        NSArray *ds = (NSArray*)[self.dataSource dataAtIndex:index];
        return [MSNGoodsTableCell heightForItems:ds width:tableView.width];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isHeader = ([self.dataSource.sort isEqualToString:SORT_TIME] && indexPath.row%2==0);
    if (isHeader) {
        NSString *identifier = @"h-cell";
        MSNGoodsHeaderTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil){
            cell = [[MSNGoodsHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = nil;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, tableView.width-20, 12)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithRGBA:0xF2deddff];
            [cell addSubview:label];
            label.tag = 110;
        }
        UILabel *label = (UILabel*)[cell viewWithTag:110];
        int index = indexPath.row/2;
        label.text = [NSString stringWithFormat:@"%@上新",[self.dataSource keyAtIndex:index]];
        NSArray *ds = [self.dataSource dataAtIndex:index];
        if (ds.count>0) {
            MSNGoodsItem *item = [ds objectAtIndex:0];
            cell.headerUserInfo = item.shop_id;
        }
        return cell;
    }
    else {
        NSString *identifier = @"cell";
        MSNGoodsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[MSNGoodsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        int index = [self.dataSource.sort isEqualToString:SORT_TIME]?(indexPath.row)/2:indexPath.row;
        NSArray *ds = [self.dataSource dataAtIndex:index];
        if ( indexPath.section < ds.count )
        {
            cell.items = ds;
            [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor colorWithWhite:1.0f alpha:0.8f] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xCCCCCCAA]  sectionRowNumbers:1];
        }
        cell.controller = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MSNGoodsHeaderTableCell class]]) {
        NSString *shopId = [(MSNGoodsHeaderTableCell*)cell headerUserInfo];
        if (shopId.length>0) {
            MSNShopInfo *info = [[MSNShopInfo alloc] init];
            info.shop_id = shopId;
            MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
            controller.shopInfo = info;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}


- (void)refreshData
{
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [self.tableView triggerRefresh];
}

- (BOOL)needsRefreshData
{
    return self.dataSource.info.count == 0;
}

- (void)selectedAsChild
{
    if ( [self needsRefreshData]) {
        [self refreshData];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)deselectedAsChild
{
    int sections = [self numberOfSectionsInTableView:self.tableView];
    for (int section=0; section<sections; section++) {
        int rows = [self tableView:self.tableView numberOfRowsInSection:section];
        for (int row=0; row<rows; row++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            if ( [cell isKindOfClass:[MSNGoodsTableCell class]] ) {
                if ([[self.tableView visibleCells] indexOfObject:cell]==NSNotFound)
                [(MSNGoodsTableCell*)cell clearMemory];
            }
        }
    }
}

- (void)loadMore
{
    [self loadData:(_page+1) delay:0.50f];
}

- (void)loadData:(int)page
{
    [self loadData:page delay:0.10];
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
}

- (void)receiveData:(MSNGoodsList*)data page:(int)page
{
    if(page == 1){
        [self.tableView refreshDone];
        self.dataSource = data;
    }
    else {
        [self.dataSource append:data];
    }
    _page = page;
    [self.dataSource group];
    [self setMoreDataAction:(data.next_page==1) tableView:self.tableView];
    [self.tableView reloadData];
    LOG_DEBUG(@"%@",[data description]);
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    [self refreshData];
}

- (NSArray*)allGoodsItems
{
    return [self.dataSource allSortedItems];
}

@end
