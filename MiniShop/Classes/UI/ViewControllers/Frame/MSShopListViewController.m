//
//  MSShopListViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//
//  店铺列表
//  系统推荐的店铺 和 我关注的店铺
//

#import "MSShopListViewController.h"
#import "MSRecmdList.h"
#import "MSShopInfoCell.h"
#import "UIColor+Mini.h"
#import "EGOUITableView.h"
#import "MSWebChatUtil.h"
#import "MSShopGalleryViewController.h"
#import "MRLoginViewController.h"

@interface MSShopListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataSource;
@end

@implementation MSShopListViewController

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
}

- (void)setBackGroudImage:(NSString *)imageName
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( self.type == ERecommend )
    {
        self.navigationItem.title = @"店铺推荐";
    }
    else if ( self.type == EFollowed )
    {
        self.navigationItem.title = @"正在关注";
        [self setNaviRightButtonImage:@"navi_bar_share" target:self action:@selector(shareAll)];
    }
    [self createTableView];
    [self setNaviBackButton];

    [self loadData];
}

- (void)createTableView
{
    self.tableView = [self createPlainTableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSShopInfo *info = [self.dataSource objectAtIndex:indexPath.row];
    return [MSShopInfoCell height:info];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSShopInfo *info = [self.dataSource objectAtIndex:indexPath.row];
    MSShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [cell.button addTarget:self action:@selector(actionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRGBA:0xefefefff];
        [cell.shareButton addTarget:self action:@selector(shareShop:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    if ( self.type == EFollowed )
    {
        cell.showsShareButton = YES;
        cell.shareButton.userInfo = info;      
    }
    else
    {
        cell.showsShareButton = NO;
    }
    cell.shopInfo = info;
    cell.button.userInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSShopInfo *info = [self.dataSource objectAtIndex:indexPath.row];
    if ( info.shop_id > 0 ) {
        MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
        controller.shopInfo = info;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [self actionGoToShopping:info];
    }

}

- (void)actionButtonTap:(MiniUIButton*)button
{
    __PSELF__;
    [self userAuth:^{
        MSShopInfo *info = button.userInfo;
        [pSelf showWating:nil];
        [[ClientAgent sharedInstance] like:@"shop" action:info.like?@"off":@"on" mid:info.shop_id block:^(NSError *error,  MSObject* data, id userInfo, BOOL cache) {
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
                    } cancelButtonTitle:@"忽略" otherButtonTitles:@"去登陆/注册", nil];
                }
                else {
                    info.like = !info.like;
                    [MSShopInfoCell resetButtonState:button shopInfo:info];
                }
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    }];
    
}

- (void)loadData
{
    [self showWating:nil];
    if ( self.type == ERecommend )
    {
        __PSELF__;
        [[ClientAgent sharedInstance] recommendlist:nil block:^(NSError *error, MSRecmdList* data, id userInfo, BOOL cache) {
            [self dismissWating];
            if ( error == nil && data != nil )
            {
               pSelf.dataSource = data.recommend_shop_info;
               [pSelf.tableView reloadData];
            }
        }];
    }
    else if ( self.type == EFollowed )
    {
        __PSELF__;
        [[ClientAgent sharedInstance] shoplist:nil block:^(NSError *error, MSFollowedList* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil && data != nil )
            {
                pSelf.dataSource = data.like_shop_info;
                [pSelf.tableView reloadData];
            }
        }];
    }
}

- (void)shareAll
{
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的店铺到" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareShopList:self.dataSource scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareShopList:self.dataSource scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}

- (void)shareShop:(MiniUIButton *)button
{
    MSShopInfo *info = button.userInfo;
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
