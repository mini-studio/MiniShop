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
#import "UIColor+Mini.h"
#import "MSNShopDetailViewController.h"
#import "MRLoginViewController.h"
#import "MSWebChatUtil.h"
#import "MSNAddShopViewController.h"

@interface MSNShopListViewController () <MSNShopInfoCellDelegate>
@property (nonatomic,strong)MSNShopList   *dataSource;
@property (nonatomic) int page;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic,strong)MiniUIButton *userButton;
@end

@implementation MSNShopListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFavListChanged:)
                                                     name:NOTI_FAV_CHANGE
                                                   object:nil];
        self.needRefresh = NO;
        self.listType = EFavorite;
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
	[self setNaviBackButton];
    [self createTableView];
    [self createNaviRightButton];
    self.naviTitleView.title = self.cTitle;
}

- (void)createNaviRightButton
{
    [self setNaviRightButtonImage:@"add_b" target:self action:@selector(actionNaviRightButtonTap:)];
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
	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataSource.info.count>0 && !self.needRefresh) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.tableView triggerRefresh];
    }
    [self resetUserButton];
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

- (void)receiveData:(MSNShopList *)data page:(int)page
{
    _page = page;
    if ( page == 1) {
        [self.tableView refreshDone];
        self.dataSource = data;
        if ((data==nil || data.info.count==0) &&EFavorite==self.listType) {
            [self showEmptyView];
        }
        else {
            [self removeEmptyView];
        }
    }
    else {
        [self.dataSource append:data];
    }
    [self.tableView reloadData];
    [self setMoreDataAction:(data.next_page==1) tableView:self.tableView];
    [self.tableView reloadData];
    LOG_DEBUG(@"%@",[data description]);
}

- (void)loadData
{
    if (self.listType== EFavorite) {
        [self.tableView triggerRefresh];
    }
    else {
        [self loadGroup];
    }
}

- (void)loadGroup
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] groupshopinfo:self.ids  block:^(NSError *error, MSNShopList *data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            data.next_page = 0;
            [pSelf receiveData:data page:1];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)loadMore
{
    [self loadFavShopListData:(_page+1)];
}

- (void)loadFavShopListData:(int)page
{
    __PSELF__;
    [[ClientAgent sharedInstance] myshoplist:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
         [pSelf dismissWating];
        if (error==nil) {
            [pSelf receiveData:data page:page];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)favShop:(MSNShopInfo*)shopInfo
{
    shopInfo.user_like = 1;
    NSInteger index = [self.dataSource.info indexOfObject:shopInfo];
    if (index!=NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView reloadData];
    }
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            shopInfo.user_like = 1;
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)cancelFavShop:(MSNShopInfo*)shopInfo
{
    shopInfo.user_like = 0;
    NSInteger index = [self.dataSource.info indexOfObject:shopInfo];
    if (index!=NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView reloadData];
    }
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"off" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            shopInfo.user_like = 0;
        }
        else {
            [pSelf showErrorMessage:error];
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
    shareButton.center = CGPointMake(toolbar.width-shareButton.width/2-40,centerY);
    [toolbar addSubview:shareButton];
    [shareButton addTarget:self action:@selector(actionToolBarShare:) forControlEvents:UIControlEventTouchUpInside];
    self.userButton = [MiniUIButton createToolBarButton:@"注册/登录" imageName:nil hImageName:nil];
    [toolbar addSubview:self.userButton];
    [self resetUserButton];
}

- (void)showEmptyView
{
    UIView *view = [self.contentView viewWithTag:100];
    if (view==nil) {
        view = [[UIView alloc] initWithFrame:self.contentView.bounds];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_back"]];
        imageView.center = CGPointMake(view.width/2, 30+imageView.height/2);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, imageView.width-60, imageView.height-30)];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"你还没有收藏任何店铺，\n你的商城空空如也";
        label.textColor = [UIColor colorWithRGBA:0xb08953FF];
        label.font = [UIFont systemFontOfSize:20];
        label.backgroundColor = [UIColor clearColor];
        [imageView addSubview:label];
        [view addSubview:imageView];
        [self.contentView addSubview:view];
        view.tag = 100;
    }
}

- (void)removeEmptyView
{
    UIView *view = [self.contentView viewWithTag:100];
    if (view!=nil) {
        [view removeFromSuperview];
    }
}

- (void)resetUserButton
{
    [self.userButton removeTarget:self action:@selector(actionToolBarReg:) forControlEvents:UIControlEventTouchUpInside];
    if (WHO==nil) {
        [self.userButton setTitle:@"注册/登录" forState:UIControlStateNormal];
        [self.userButton addTarget:self action:@selector(actionToolBarReg:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.userButton setTitle:[NSString stringWithFormat:@"你好,%@",WHO.usernick] forState:UIControlStateNormal];
    }
    [self.userButton sizeToFit];
    CGFloat maxWidth = self.contentView.width/2;
    if (self.userButton.width > maxWidth) {
        self.userButton.width = maxWidth;
    }
    self.userButton.center = CGPointMake(40+self.userButton.width/2,self.userButton.superview.height/2);
}

- (void)actionToolBarShare:(MiniUIButton*)button
{
    [MSWebChatUtil shareShopList:self.dataSource.info controller:self];
}

- (void)actionToolBarReg:(MiniUIButton*)button
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionNaviRightButtonTap:(MiniUIButton*)button
{
    MSNAddShopViewController *controller = [[MSNAddShopViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)handleFavListChanged:(NSNotification *)notification
{
    self.needRefresh = YES;
}

@end
