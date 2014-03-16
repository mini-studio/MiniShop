//
//  MSNShopListViewController.m
//  MiniShop
//  我的商城列表
//  Created by Wuquancheng on 14-2-9.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopListViewController.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "EGOUITableView.h"
#import "MSUIMoreDataCell.h"
#import "UIColor+Mini.h"
#import "MSNShopDetailViewController.h"
#import "MRLoginViewController.h"
#import "MSWebChatUtil.h"

@interface MSNShopListViewController () <MSNShopInfoCellDelegate>
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic) int page;
@end

@implementation MSNShopListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	[self setNaviBackButton];
    self.naviTitleView.title = self.ctitle;
    [self createTableView];
}

- (void)createTableView
{
    self.tableView = [self createEGOTableView];
    self.tableView.height = self.contentView.height-44;
    [self.contentView addSubview:self.tableView];
    [self createToolbar:44];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf loadFavShopListData:1];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadFavShopListData:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)backgroundColor
{
    return [UIColor colorWithRGBA:0xfaf1f2ff];
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
    if ( cell == nil ) {
        cell = [[MSNShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.shopInfoDelegate = self;
        cell.contentView.backgroundColor = [self backgroundColor];
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

- (void)recevieData:(MSNShopList*)data page:(int)page
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
    [self loadFavShopListData:(_page+1)];
}

- (void)loadFavShopListData:(int)page
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] myshoplist:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
         [pSelf dismissWating];
        if (error==nil) {
            [pSelf recevieData:data page:page];
        }
        else {
            [pSelf showErrorMessage:error];
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
        [pSelf dismissWating];
        if (error==nil) {
            shopInfo.user_like = 0;
            [pSelf.tableView reloadData];
        }
        else {
            [self showErrorMessage:error];
        }
    }];
}

- (void)createToolbar:(CGFloat)height
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height-height, self.contentView.width, height)];
    toolbar.backgroundColor = [UIColor colorWithRGBA:0xf7eeefff];
    [self.contentView addSubview:toolbar];

    CGFloat centerY = toolbar.height/2;
    MiniUIButton *shareButton = [MiniUIButton createToolBarButton:@"分享此列表" imageName:nil hImageName:nil];
    shareButton.center = CGPointMake(toolbar.width-100,centerY);
    [toolbar addSubview:shareButton];
    [shareButton addTarget:self action:@selector(actionToolBarShare:) forControlEvents:UIControlEventTouchUpInside];
    MiniUIButton *button = nil;
    if (WHO==nil) {
        button = [MiniUIButton createToolBarButton:@"注册/登录" imageName:nil hImageName:nil];
        button.center = CGPointMake(100,centerY);
        [toolbar addSubview:button];
        [button addTarget:self action:@selector(actionToolBarReg:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        shareButton.centerX = toolbar.width/2;
    }
}

- (void)actionToolBarShare:(MiniUIButton*)button
{
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareShopList:self.dataSource.info scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareShopList:self.dataSource.info scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}

- (void)actionToolBarReg:(MiniUIButton*)button
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
