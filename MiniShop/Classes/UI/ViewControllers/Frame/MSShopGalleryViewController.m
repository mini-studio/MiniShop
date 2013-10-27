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
#import "MSWebChatUtil.h"
#import "MSJoinViewController.h"
#import "MRLoginViewController.h"
#import "MRLoginViewController.h"

@interface MSShopGalleryViewController ()<UITableViewDataSource,UITabBarDelegate>
@property (nonatomic,strong) EGOUITableView *tableView;
@property (nonatomic,strong) MSShopGalleryList *dataSource;
@property (nonatomic,strong) MiniUIButton      *followButton;
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

- (void)setShopInfo:(MSShopInfo *)shopInfo
{
    _shopInfo =  shopInfo;
    _notiInfo = [[MSNotiItemInfo alloc] init];
    _notiInfo.shop_id = _shopInfo.shop_id;
    _notiInfo.shop_title = _shopInfo.realTitle;
    _notiInfo.name = _shopInfo.realTitle;
}

- (void)loadView
{
    [super loadView];
    self.tableView = (EGOUITableView*)[self createPlainTableView];
    if ( !self.autoLayout )
    {
        if ( MAIN_VERSION < 7 ) {
        self.tableView.top = self.navigationController.navigationBar.height;
        self.tableView.height = self.view.height-self.tableView.top;
        }
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    self.tableView.tableHeaderView = view;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 30)];
    [view addSubview:headerView];
    headerView.text = self.notiInfo.shop_title;
    headerView.font = [UIFont systemFontOfSize:18];
    headerView.textColor = [UIColor colorWithRGBA:0x737270FF];
    headerView.textAlignment = NSTextAlignmentCenter;
    headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNaviView];
    //[self setNaviBackButton];
    self.navigationItem.title = @"上新";
    [self loadData:0];
}

- (void)createNaviView
{
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_back"] highlightedImage:[UIImage imageNamed:@"navi_back_h"]];
    button.width = 30;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_message"] highlightedImage:[UIImage imageNamed:@"navi_message_h"]];
    button.width = 30;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(actionGoToSocial) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width-80, self.navigationController.navigationBar.height)];
    titleView.backgroundColor = [UIColor clearColor];
   
    if ( self.dataSource.user_is_like_shop )
    {
        button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_fav"] highlightedImage:[UIImage imageNamed:@"navi_fav_h"]];
    }
    else {
        button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_fav_h"] highlightedImage:[UIImage imageNamed:@"navi_fav"]];
    }
    button.frame = CGRectMake(0, 0, 30, 30);
    button.center = CGPointMake(titleView.width/3-10, titleView.height/2);
    [titleView addSubview:button];
    self.followButton = button;
    
    button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_share"] highlightedImage:[UIImage imageNamed:@"navi_share_h"]];
    button.frame = CGRectMake(0, 0, 30, 30);
    button.center = CGPointMake(2*titleView.width/3+10, titleView.height/2);
    [titleView addSubview:button];
    [button addTarget:self action:@selector(actionShare) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.body_info.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 24)];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time_bg"]];
    CGRect fr = view.bounds;
    fr.origin.x = 24;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:fr];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor =  [UIColor colorWithRGBA:0x6c6c6cff];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:titleLabel];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_icon"]];
    imageView.frame = CGRectMake(6, 4, 14, 14);
    [view addSubview:imageView];
    MSShopGalleryInfo *info = [self.dataSource.body_info objectAtIndex:section];
    titleLabel.text = [NSString stringWithFormat:@"%@ 上新",info.item_info.publish_time];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSShopGalleryInfo *info = [self.dataSource.body_info objectAtIndex:indexPath.section];
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
    MSShopGalleryInfo *info = [self.dataSource.body_info objectAtIndex:indexPath.section];
    info.item_info.shop_name = self.notiInfo.name;
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
    [self.followButton removeTarget:self action:@selector(unFollowShop) forControlEvents:UIControlEventTouchUpInside];
    [self.followButton removeTarget:self action:@selector(followShop) forControlEvents:UIControlEventTouchUpInside];
    if ( self.dataSource.user_is_like_shop )
    {
        [self.followButton setImage:[UIImage imageNamed:@"navi_fav"] forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@"navi_fav_h"] forState:UIControlStateHighlighted];
        [self.followButton addTarget:self action:@selector(unFollowShop) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.followButton setImage:[UIImage imageNamed:@"navi_fav_h"] forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@"navi_fav"] forState:UIControlStateHighlighted];
        [self.followButton addTarget:self action:@selector(followShop) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)followShop
{
    __PSELF__;
  //  [self userAuth:^{
        [pSelf showWating:nil];
        NSInteger shopid = ((MSShopGalleryInfo*)[self.dataSource.body_info objectAtIndex:0]).item_info.shop_id;
        
        [[ClientAgent sharedInstance] like:@"shop" action:@"on" mid:shopid block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil )
            {
                if ( data.show_msg.length > 0 ) {
                    [MiniUIAlertView showAlertWithTitle:@"提示" message:data.show_msg block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
                        if ( buttonIndex != alertView.cancelButtonIndex ) {
                            MRLoginViewController *controller = [[MRLoginViewController alloc] init];
                            controller.loginblock = ^(BOOL login) {
                                if ( login ) {
                                    [pSelf.navigationController popViewControllerAnimated:NO];
                                }
                            };
                            [pSelf.navigationController pushViewController:controller animated:YES];
                        }
                    } cancelButtonTitle:@"忽略" otherButtonTitles:@"去登录/注册", nil];
                }
                else {
                [pSelf showMessageInfo:@"已经关注" delay:2];
                pSelf.dataSource.user_is_like_shop = 1;
                [pSelf updateUIAfterLoadData];
                }
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];

//    }];
}

- (void)unFollowShop
{
    __PSELF__;
//    [self userAuth:^{
        [pSelf showWating:nil];
        NSInteger shopid = ((MSShopGalleryInfo*)[self.dataSource.body_info objectAtIndex:0]).item_info.shop_id;
        [[ClientAgent sharedInstance] like:@"shop" action:@"off" mid:shopid block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil )
            {
                if ( data.show_msg.length > 0 ) {
                    [MiniUIAlertView showAlertWithTitle:@"提示" message:data.show_msg block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
                        if ( buttonIndex != alertView.cancelButtonIndex ) {
                            MRLoginViewController *controller = [[MRLoginViewController alloc] init];
                            controller.loginblock = ^(BOOL login) {
                                if ( login ) {
                                    [pSelf.navigationController popViewControllerAnimated:NO];
                                }
                            };
                            [pSelf.navigationController pushViewController:controller animated:YES];
                        }
                    } cancelButtonTitle:@"忽略" otherButtonTitles:@"去登录/注册", nil];
                }
                else {
                [pSelf showMessageInfo:@"已经取消关注" delay:2];
                pSelf.dataSource.user_is_like_shop = 0;
                [pSelf updateUIAfterLoadData];
                }
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
//    }];
}

- (void)loadData:(int)page
{
    if ( page == 0 )
    {
        __PSELF__;
        [self showWating:nil];
        [[ClientAgent sharedInstance] newsbody12:self.notiInfo.shop_id block:^(NSError *error, MSShopGalleryList* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
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
        [[ClientAgent sharedInstance] goodsdetail12:self.notiInfo.shop_id page:page block:^(NSError *error, MSGoodsList* data, id userInfo, BOOL cache) {
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
        item.shop_title = self.notiInfo.name;
        item.shop_id = self.notiInfo.shop_id;
    }
    return array;
}

- (void)handleTouchItem:( MSGoodItem *)item
{
    MSGoodsList *data =[[MSGoodsList alloc] init];
    NSArray *array = [self allItems];
    data.body_info = array;
    data.shop_name = self.notiInfo.name;
    data.shop_id = self.notiInfo.shop_id;
    NSInteger index = [array indexOfObject:item];
    MSDetailViewController *c = [[MSDetailViewController alloc] init];
    c.mtitle = self.notiInfo.name;
    c.defaultIndex = index;
    c.more = NO;
    c.goods = data;
    [self.navigationController pushViewController:c animated:YES];
}

- (void)actionGoToSocial
{
    MSJoinViewController *controller = [[MSJoinViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionFav
{
    
}

- (void)actionShare
{
    MSShopInfo *info = [[MSShopInfo alloc] init];
    info.shop_id = self.notiInfo.shop_id;
    info.shop_title = self.notiInfo.name;
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的店铺到" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareShop:info scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareShop:info scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}

@end
