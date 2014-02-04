//
//  MSFbViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSProfileViewController.h"
#import "UITableViewCell+GroupBackGround.h"
#import "UIColor+Mini.h"
#import "MSFeedbackViewController.h"
#import "MiniUIWebViewController.h"
#import "UILabel+Mini.h"
#import "MSUIAuthWebViewController.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MiniUISegmentView.h"
#import "MSAboutViewController.h"
#import "MRLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

// 间距配置
#define KCopyrightHeight            62.0f

// 字体颜色配置
#define KLabelColor          0x898989AA

// 字体高度配置
#define KLabelHeight          12.0f

@interface MSProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableDictionary *dictionary;
@property (nonatomic) BOOL importing;
@end

@implementation MSProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)resetDataSource
{
    if ( WHO != nil ) {
        self.dictionary[@"0"] = @[@{@"mid_text":WHO.usernick}];
    }
    else {
        self.dictionary[@"0"] = @[
                                 @{@"action":WHO==nil?@"actionForLogin":@"actionForLogout",@"text":WHO==nil?@"":WHO.usernick,@"right_text":WHO==nil?@"登录或注册":@"注销"}
                                 ];
    }
    self.dictionary[@"1"] = @[
                              @{@"action":@"actionForPotentialList",@"text":@"纠结清单",@"icon":@"icon_kink"}
                              ];
    self.dictionary[@"2"] = @[
                              @{@"action":@"actionForMyFollow",@"text":@"正在关注的店铺",@"icon":@"icon_following"},
                              @{@"action":@"actionForImportFav",@"text":@"导入淘宝收藏夹",@"icon":@"icon_import_taobao"},
                              ];
}

- (void)loadView
{
    [super loadView];
    
    self.tableView  = [self createGroupedTableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    header.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,140 )];
    footer.backgroundColor = self.tableView.backgroundColor;
    UILabel *label = [UILabel LabelWithFrame:CGRectZero
                                     bgColor:[UIColor colorWithRGBA:0x55555555]
                                        text:@"    淘宝快捷入口"
                                       color:[UIColor colorWithRGBA:0x555555ff]
                                        font:[UIFont boldSystemFontOfSize:16]
                                   alignment:NSTextAlignmentLeft
                                 shadowColor:nil
                                  shadowSize:CGSizeZero];
    label.frame = CGRectMake(0, 10, footer.width, 30);
    [footer addSubview:label];
    NSArray *buttonsInfo = @[
                             @{@"image":@"my_goods",@"action":@"actionForGoToPurchase"},
                             @{@"image":@"my_cart",@"action":@"actionForGoToBag"},
                             @{@"image":@"logistics",@"action":@"actionForGoToLogistics"}
                             ];
    CGFloat buttonW = (footer.width - 60)/3;
    CGFloat buttonH = buttonW*0.69;
    for ( int index = 0; index < 3; index++ )
    {
        id data = [buttonsInfo objectAtIndex:index];
        NSString *normal = [NSString stringWithFormat:@"%@_normal",[data valueForKey:@"image"]];
        NSString *highlighted = [NSString stringWithFormat:@"%@_selected",[data valueForKey:@"image"]];
        MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:normal] highlightedImage:[UIImage imageNamed:highlighted]];
        [button addTarget:self action:NSSelectorFromString([data valueForKey:@"action"]) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(15 + (index*(buttonW+15)), label.bottom + 10, buttonW, buttonH);
        [footer addSubview:button];
    }
    self.tableView.tableFooterView = footer;
     [self.contentView addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = @"我的";    
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetDataSource];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    if ( self.importing )
    {
        [self dismissWating];
        self.importing = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dictionary.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",section]];
    return array.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor = [UIColor colorWithRGBA:0x555555ff];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_accessory"]];
        cell.detailTextLabel.font = cell.textLabel.font;
        cell.detailTextLabel.textColor = cell.textLabel.textColor;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:cell.bounds];
        [cell addSubview:nameLabel];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.tag = 100;
        nameLabel.backgroundColor = cell.textLabel.backgroundColor;
        nameLabel.font = cell.textLabel.font;
        nameLabel.textColor = cell.textLabel.textColor;
    }
    NSArray *dataSource = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xebebebff] sectionRowNumbers:dataSource.count];
    id data = [dataSource objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    NSString *midText = [data valueForKey:@"mid_text"];
    if (midText.length > 0) {
        cell.textLabel.text = nil;
        nameLabel.text = midText;
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        nameLabel.hidden = NO;
        cell.accessoryView = nil;
    }
    else {
        nameLabel.hidden = YES;
        cell.textLabel.text = [data valueForKey:@"text"];
        cell.detailTextLabel.text =[data valueForKey:@"right_text"];
        cell.imageView.image = [UIImage imageNamed:[data valueForKey:@"icon"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_accessory"]];
    }
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

- (void)actionForPotentialList
{
    //[self userAuth:^{
//        MSPotentialViewController *controller = [[MSPotentialViewController alloc] init];
//        [self.navigationController pushViewController:controller animated:YES];
    //}];
   
}


- (void)actionFunction:(NSString *)url
{
    [self showWating:nil];
    __PSELF__;
    [[MSSystem sharedInstance] checkVersion:^{
        if ( [MSSystem sharedInstance].version.auth == 1 )
        {
            [pSelf dismissWating];
            MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:url title:nil toolbar:YES];
            [pSelf.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [[ClientAgent sharedInstance] auth:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if ( error == nil )
                {
                    MSUIAuthWebViewController *controller = [[MSUIAuthWebViewController alloc] init];
                    controller.htmlStr = data;
                    [controller setCallback:^(bool state ) {
                        [pSelf.navigationController popViewControllerAnimated:NO];
                        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:url title:nil toolbar:YES];
                        [pSelf.navigationController pushViewController:controller animated:YES];
                    }];
                    [pSelf.navigationController pushViewController:controller animated:YES];
                }
            }];
        }
    }];
}

- (void)actionForImportFav
{
    [MobClick event:MOB_IMPORT_FAV];
    if ( self.importing ) return;
    __PSELF__;
    //[self userAuthWithString:LOGIN_IMPORT_FAV_PROMPT block:^{
        pSelf.importing  = YES;
        [pSelf showWating:nil];
        [[ClientAgent sharedInstance] importFav:pSelf userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            pSelf.importing = NO;
            if ( error == nil )
            {
                LOG_DEBUG(@"%@",data);
//                MSShopGroupListViewController *controller = [[MSShopGroupListViewController alloc] init];
//                controller.type = EImportFav;
//                controller.favData = data;
//                [pSelf.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
        }];
    //}];
}

- (void)actionForMyFollow
{
    __PSELF__;
    //[pSelf userAuth:^{
//        MSShopListViewController *controller = [[MSShopListViewController alloc] init];
//        controller.type = EFollowed;
//        [pSelf.navigationController pushViewController:controller animated:YES];
    //}];
}

//去淘宝收藏夹
- (void)actionForGoToFav
{
    __PSELF__;
    //[self userAuth:^{
        [MobClick event:MOB_ENTER_TAOBAO_FAV];
        [pSelf actionFunction:[ClientAgent jumpToTaoBaoUrl:@"fav"]];
    //}];

}
//已经购买的
- (void)actionForGoToPurchase
{
    __PSELF__;
    //[self userAuth:^{
    [MobClick event:MOB_ENTER_TAOBAO_ORDER];
    [pSelf actionFunction:[ClientAgent jumpToTaoBaoUrl:@"order"]];
    //}];

}
//我的购物车
- (void)actionForGoToBag
{
    __PSELF__;
    //[self userAuth:^{
    [MobClick event:MOB_ENTER_TAOBAO_BAG];
    [pSelf actionFunction:[ClientAgent jumpToTaoBaoUrl:@"bag"]];
    //}];

}
//物流
- (void)actionForGoToLogistics
{
    __PSELF__;
    //[self userAuth:^{
    [MobClick event:MOB_ENTER_TAOBAO_LOGISTICS];
    [pSelf actionFunction:[ClientAgent jumpToTaoBaoUrl:@"logistics"]];
    //}];
}

- (void)actionForLogin
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForLogout
{
    __PSELF__;
    [MiniUIAlertView showAlertWithTitle:@"亲，您真的要退出登录？" message:nil block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            [MSSystem logout];
            [pSelf resetDataSource];
            [pSelf.tableView reloadData];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
}



@end
