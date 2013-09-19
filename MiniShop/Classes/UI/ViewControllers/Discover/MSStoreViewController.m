//
//  MSStoreViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSStoreViewController.h"
#import "MSShopGroupListViewController.h"
#import "MSDefine.h"
#import "UIColor+Mini.h"
#import "MSShopListViewController.h"
#import "MSSearchKeyInfo.h"
#import "MiniUIActionSheetPickerView.h"
#import "MSVerifyViewController.h"
#import "MSSearchCategoryViewController.h"
#import "MSTopicViewController.h"
#import <objc/message.h>

@interface MSStoreViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) bool importing;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSDictionary *dictionary;
@end

@implementation MSStoreViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = NO;
        if (self) {
            self.dictionary = @{@"0":@[
                                        @{@"action":@"actionForRecommend",@"text":@"骚店推荐",@"icon":@"icon_recmd_shop"},
                                        @{@"action":@"actionForAllOnline",@"text":@"全部店铺上新",@"icon":@"icon_all_goods_online"},
                                        @{@"action":@"actionForVerify",@"text":@"审核求收录",@"icon":@"icon_verify"}                                        
                                        ],
                                @"1":@[
                                        @{@"action":@"actionForSearch",@"text":@"搜索店铺",@"icon":@"icon_search"},
                                        @{@"action":@"actionForViewByCategory",@"text":@"按分类查看店铺",@"icon":@"icon_search_cate"}
                                    ]
                                };
        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"关注店铺";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = nil;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,20)];
    header.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableHeaderView = header;
    [self.view addSubview:self.tableView];
}

- (void)setNaviBackButton
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.importing = NO;
    [self dismissWating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dictionary.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",section]];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor = [UIColor colorWithRGBA:0x555555ff];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_accessory"]];
    }
    NSArray *dataSource = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xebebebff] sectionRowNumbers:dataSource.count];
    id data = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [data valueForKey:@"text"];
    cell.imageView.image = [UIImage imageNamed:[data valueForKey:@"icon"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *dataSource = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    id data = [dataSource objectAtIndex:indexPath.row];
    NSString *action = [data valueForKey:@"action"];
    if ( action.length > 0 )
    {
        SEL sel = NSSelectorFromString(action);
        if ( [self respondsToSelector:sel] )
        {
            objc_msgSend(self,sel);
        }
    }
}

- (void)actionForImportFav
{
    [MobClick event:MOB_IMPORT_FAV];
    if ( self.importing ) return;
    self.importing  = YES;
    __PSELF__;
    [self userAuthWithString:LOGIN_IMPORT_FAV_PROMPT block:^{
        [pSelf showWating:nil];
        [[ClientAgent sharedInstance] importFav:self userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            pSelf.importing = NO;
            if ( error == nil )
            {
                LOG_DEBUG(@"%@",data);
                MSShopGroupListViewController *controller = [[MSShopGroupListViewController alloc] init];
                controller.type = EImportFav;
                controller.favData = data;
                [pSelf.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    }];
}


- (void)actionForAllOnline
{
    MSTopicViewController *controller = [[MSTopicViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForRecommend
{
    MSShopListViewController *controller = [[MSShopListViewController alloc] init];
    controller.type = ERecommend;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForVerify
{
    MSVerifyViewController *controller = [[MSVerifyViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForMyFollow
{
    MSShopListViewController *controller = [[MSShopListViewController alloc] init];
    controller.type = EFollowed;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)actionForSearch
{
    MSShopGroupListViewController *controller = [[MSShopGroupListViewController alloc] init];
    controller.type = ESearch;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForViewByCategory
{
    MSSearchCategoryViewController *controller = [[MSSearchCategoryViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
