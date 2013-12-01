//
//  MSSearchCategoryViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSSearchCategoryViewController.h"
#import "MSSearchKeyInfo.h"
#import "UITableViewCell+GroupBackGround.h"
#import "UIColor+Mini.h"
#import "MSShopGroupListViewController.h"
#import "MSRecmdList.h"

@interface MSSearchCategoryViewController ()
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation MSSearchCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.naviTitleView.title = @"分类搜索";
    [self setNaviBackButton];
	self.tableView = [self createGroupedTableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.tableView];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchKeyList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = cell.textLabel.highlightedTextColor = [UIColor colorWithRGBA:0x555555ff];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.textColor = cell.detailTextLabel.highlightedTextColor = [UIColor lightGrayColor];
    }
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xebebebff] sectionRowNumbers:self.searchKeyList.count];
    MSSearchKeyInfo* item = [self.searchKeyList objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@家店铺",item.total];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSSearchKeyInfo* item = [self.searchKeyList objectAtIndex:indexPath.row];
    MSShopGroupListViewController *controller = [[MSShopGroupListViewController alloc] init];
    controller.type = ESearchInCategory;
    controller.key = item.first;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] recommendlist:nil block:^(NSError *error, MSRecmdList* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            pSelf.searchKeyList = data.word_info;
            [pSelf.tableView reloadData];
        }
        else
        {
            [pSelf showErrorMessage:error];
        }
    }];
}


@end
