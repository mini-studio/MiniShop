//
//  MSShopGalleryViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopGalleryViewController.h"
#import "MSNotiItemInfo.h"
#import "EGOUITableView.h"
#import "MSGoodsList.h"
#import "UIColor+Mini.h"
#import "MSGalleryGoodsCell.h"
#import "MSDetailViewController.h"

@interface MSShopGalleryViewController ()<UITableViewDataSource,UITabBarDelegate>
@property (nonatomic,strong) EGOUITableView *tableView;
@property (nonatomic,strong) MSShopGalleryList *dataSource;
@property (nonatomic) int page;
@end

@implementation MSShopGalleryViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.autoLayout = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.tableView = (EGOUITableView*)[self createPlainTableView];
    if ( !self.autoLayout )
    {
        self.tableView.top = self.navigationController.navigationBar.height;
        self.tableView.height = self.view.height-self.tableView.top;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    self.tableView.tableHeaderView = view;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 30)];
    [view addSubview:headerView];
    headerView.text = self.shopInfo.shop_title;
    headerView.font = [UIFont systemFontOfSize:18];
    headerView.textColor = [UIColor colorWithRGBA:0x737270FF];
    headerView.textAlignment = NSTextAlignmentCenter;
    headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBackButton];
    self.navigationItem.title = @"上新";
    [self loadData:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.body_info.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSShopGalleryInfo *info = [self.dataSource.body_info objectAtIndex:indexPath.row];
    return [MSGalleryGoodsCell heightWithImageCount:info.goods_info.count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSGalleryGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSGalleryGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MSShopGalleryInfo *info = [self.dataSource.body_info objectAtIndex:indexPath.row];
    info.item_info.shop_name = self.shopInfo.name;
    [cell setGalleyInfo:info];
    __PSELF__;
    [cell setHandleTouchItem:^(MSGoodItem * item) {
        [pSelf handleTouchItem:item];
    }];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIAfterLoadData
{
    if ( self.dataSource.user_is_like_shop )
    {
        [self setNaviRightButtonTitle:@"取消关注" target:self action:@selector(unFollowShop)];
    }
    else
    {
        [self setNaviRightButtonTitle:@"关注店铺" target:self action:@selector(followShop)];
    }
}

- (void)followShop
{
    [self showWating:nil];
    NSInteger shopid = ((MSShopGalleryInfo*)[self.dataSource.body_info objectAtIndex:0]).item_info.shop_id;
    __PSELF__;
    [[ClientAgent sharedInstance] like:@"shop" action:@"on" mid:shopid block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            [pSelf showMessageInfo:@"已经关注" delay:2];
            pSelf.dataSource.user_is_like_shop = 1;
            [pSelf updateUIAfterLoadData];
        }
        else
        {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)unFollowShop
{
    [self showWating:nil];
    __PSELF__;
    NSInteger shopid = ((MSShopGalleryInfo*)[self.dataSource.body_info objectAtIndex:0]).item_info.shop_id;
    [[ClientAgent sharedInstance] like:@"shop" action:@"off" mid:shopid block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            [pSelf showMessageInfo:@"已经取消关注" delay:2];
            pSelf.dataSource.user_is_like_shop = 0;
            [pSelf updateUIAfterLoadData];
        }
        else
        {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)loadData:(int)page
{
    if ( page == 0 )
    {
        __PSELF__;
        [[ClientAgent sharedInstance] newsbody12:self.shopInfo.shop_id block:^(NSError *error, MSShopGalleryList* data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                [pSelf.tableView setMoreDataAction:^{
                    [pSelf loadMore];
                } keepCellWhenNoData:NO loadSection:NO];
                pSelf.dataSource = data;
                [pSelf.tableView reloadData];
                [pSelf updateUIAfterLoadData];
                int count = 0;
                for (MSShopGalleryInfo *ginfo in data.body_info )
                {
                    count += ginfo.item_info.goods_num;
                }
                if ( count < 20 )
                {
                    [pSelf loadData:1];
                }
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    }
    else
    {
        __PSELF__;
        [[ClientAgent sharedInstance] goodsdetail12:self.shopInfo.shop_id page:page block:^(NSError *error, MSGoodsList* data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                pSelf.page = page;
                [pSelf.dataSource appendGoodItems:data.body_info];
                if ( data.next_page == 0 )
                {
                   [pSelf.tableView setMoreDataAction:nil keepCellWhenNoData:NO loadSection:NO];
                }
                [pSelf.tableView reloadData];
                [pSelf updateUIAfterLoadData];
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    }
}

- (void)loadMore
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData:(self.page+1)];
    });
}

- (NSArray*)allItems
{
    NSMutableArray *array = [NSMutableArray array];
    for (MSShopGalleryInfo *info in self.dataSource.body_info)
    {
        [array addObjectsFromArray:info.goods_info];
    }
    for ( MSGoodItem *item in array )
    {
        item.shop_title = self.shopInfo.name;
        item.shop_id = self.shopInfo.shop_id;
    }
    return array;
}

- (void)handleTouchItem:( MSGoodItem *)item
{
    MSGoodsList *data =[[MSGoodsList alloc] init];
    NSArray *array = [self allItems];
    data.body_info = array;
    data.shop_name = self.shopInfo.name;
    data.shop_id = self.shopInfo.shop_id;
    NSInteger index = [array indexOfObject:item];
    MSDetailViewController *c = [[MSDetailViewController alloc] init];
    c.mtitle = self.shopInfo.name;
    c.defaultIndex = index;
    c.more = NO;
    c.goods = data;
    [self.navigationController pushViewController:c animated:YES];
}

@end
