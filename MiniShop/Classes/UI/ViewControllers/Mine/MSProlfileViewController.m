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
#import "MSPotentialViewController.h"
#import "MSShopGroupListViewController.h"
#import "MSShopListViewController.h"
#import "MRLoginViewController.h"
#import "MSTopicViewController.h"
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
@property (nonatomic,strong)NSDictionary *dictionary;
@property (nonatomic) BOOL importing;
@end

@implementation MSProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)resetDataSource
{
    self.dictionary = @{@"0":@[
                                @{@"action":WHO==nil?@"actionForLogin":@"actionForLogout",@"text":WHO==nil?@"登录":@"注销",@"icon":@"navi_link"}
                                ],
                        @"1":@[
                                @{@"action":@"actionForPotentialList",@"text":@"纠结清单",@"icon":@"icon_kink"}
                                ],
                        @"2":@[
                                @{@"action":@"actionForMyFollow",@"text":@"正在关注的店铺",@"icon":@"icon_following"},
                                @{@"action":@"actionForImportFav",@"text":@"导入淘宝收藏夹",@"icon":@"icon_import_taobao"},
                                ]
                        };

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"我的";    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];
    
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
}

-(void)viewWillAppear:(BOOL)animated
{
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

- (void)actionForPotentialList
{
    MSPotentialViewController *controller = [[MSPotentialViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)actionFunction:(NSString *)url
{
    [self showWating:nil];
    __weak typeof (self) pSelf = self;
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
    self.importing  = YES;
    [self showWating:nil];
    __weak typeof (self) pSelf = self;
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
}

- (void)actionForMyFollow
{
    MSShopListViewController *controller = [[MSShopListViewController alloc] init];
    controller.type = EFollowed;
    [self.navigationController pushViewController:controller animated:YES];
}

//去淘宝收藏夹
- (void)actionForGoToFav
{
    [MobClick event:MOB_ENTER_TAOBAO_FAV];
    [self actionFunction:[ClientAgent jumpToTaoBaoUrl:@"fav"]];

}
//已经购买的
- (void)actionForGoToPurchase
{
    [MobClick event:MOB_ENTER_TAOBAO_ORDER];
    [self actionFunction:[ClientAgent jumpToTaoBaoUrl:@"order"]];

}
//我的购物车
- (void)actionForGoToBag
{
    [MobClick event:MOB_ENTER_TAOBAO_BAG];
    [self actionFunction:[ClientAgent jumpToTaoBaoUrl:@"bag"]];

}
//物流
- (void)actionForGoToLogistics
{
    [MobClick event:MOB_ENTER_TAOBAO_LOGISTICS];
    [self actionFunction:[ClientAgent jumpToTaoBaoUrl:@"logistics"]];
}

- (void)actionForLogin
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForLogout
{
    [MSSystem logout];
    [self resetDataSource];
    [self.tableView reloadData];
    [self remindLogin];
}



@end
