//
//  MSFbViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNSettingsViewController.h"
#import "UMFeedbackViewController.h"
#import "MRLoginViewController.h"
#import "UITableViewCell+GroupBackGround.h"
#import "UIColor+Mini.h"
#import "MiniUIWebViewController.h"
#import "UMTableViewController.h"
#import "UILabel+Mini.h"
#import "MSUIAuthWebViewController.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MiniUISegmentView.h"
#import "MSAboutViewController.h"
#import "UMFeedback.h"
#import "MSJoinViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

#define KLabelHeight          12.0f

@interface MSNSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSDictionary *dictionary;
@property (nonatomic,strong)UMFeedback *umFeedback;
@property (nonatomic,strong)UISwitch *uiSwitch;
@property (nonatomic)BOOL pushOn;
@end

@implementation MSNSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)initData
{
    self.dictionary = @{@"0":@[
                                @{@"action":@"actionForInvote",@"text":@"请赐好评,我们会更加努力"},
                                @{@"action":@"actionForMessage",@"text":@"公告消息"}
                                ],
                        @"1":@[
                                @{@"action":WHO==nil?@"actionForReg":@"actionForLogout",@"text":WHO==nil?@"登录注册":@"退出登录",@"subtext":@"登录绑定后才能参加积分活动哦~"},
                                @{@"action":@"actionForFeedback",@"text":@"微信"},
                                @{@"action":@"actionForFeedback",@"text":@"意见反馈(热线010-82858599)"},
                                ],
                        @"2":@[
                                //@{@"action":@"actionForJoin",@"text":@"加入QQ群"},
                                @{@"action":@"actionForSeller",@"text":@"消息推送提示音",@"type":@"switch",@"acc":@"0"},
                                @{@"action":@"actionForClearCache",@"text":@"清除缓存",@"acc":@"0"}
                                ],
                        @"3":@[
                                @{@"action":@"actionForRecommend",@"text":@"精彩应用推荐"},
                                @{@"action":@"actionForAbout",@"text":@"关于"}
                                ]
                        };

}

- (void)dealloc
{
    _umFeedback.delegate = nil;
}

- (void)loadView
{
    [super loadView];
     self.uiSwitch = [[UISwitch alloc] init];
    [self.uiSwitch addTarget:self action:@selector(actionPushSwitch:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = @"更多";    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = nil;
    [self.contentView addSubview:self.tableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,20 )];
    header.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableHeaderView = header;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
    [self.tableView reloadData];
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
        cell.accessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_accessory"]];
        UISwitch *uiSwitch = [[UISwitch alloc] init];
        uiSwitch.center = CGPointMake(cell.width-uiSwitch.width-8, 25);
        uiSwitch.hidden = YES;
        uiSwitch.tag = 1000;
        [cell addSubview:uiSwitch];
    }
    NSArray *dataSource = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xebebebff] sectionRowNumbers:dataSource.count];
    id data = [dataSource objectAtIndex:indexPath.row];
    NSString *type = [data valueForKey:@"type"];
    UISwitch *uiSwitch = (UISwitch *)[cell viewWithTag:1000];
    if ([@"switch" isEqualToString:type]){
        [cell addSubview:self.uiSwitch];
        self.uiSwitch.center = CGPointMake(cell.width-uiSwitch.width-8, 25);uiSwitch.hidden = NO;
        self.uiSwitch.on = self.pushOn;
    }
    NSString *acc = [data valueForKey:@"acc"];
    if ([@"0" isEqualToString:acc]) {
        cell.accessoryView.hidden = YES;
    }
    else {
        cell.accessoryView.hidden = NO;
    }
    cell.textLabel.text = [data valueForKey:@"text"];
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

- (void)actionForHelp
{
    MiniUIWebViewController *controller = [[MiniUIWebViewController alloc] init];
    controller.ctitle = @"帮助";
    NSString* requestStr = [NSString stringWithFormat:@"%@/api/help?usernick=%@&imei=%@",[ClientAgent host], NICK, UDID];
    [self.navigationController pushViewController:controller animated:YES];
    [controller loadURL:[NSURL URLWithString:requestStr]];
}

- (void)actionForFeedback
{
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = @"51375dd152701512ce000002";
    [self.navigationController pushViewController:feedbackViewController animated:YES];

}
//投票
- (void)actionForInvote
{
    NSString* appstoreReview = [MSSystem sharedInstance].appStoreUrl;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appstoreReview]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appstoreReview]];
    } else {
        [self showMessageInfo:@"抱歉，您的设备暂不支持此功能！" delay:2];
    }
}

- (void)actionForMessage
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] placard:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            MiniUIWebViewController *controller = [[MiniUIWebViewController alloc] init];
            [controller loadContent:data title:@"系统公告"];
            [pSelf.navigationController pushViewController:controller animated:YES];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}
//关于
- (void)actionForAbout
{
    MSAboutViewController *controller = [[MSAboutViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
//卖家一键报名处
- (void)actionForJoin
{
//    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:@"http://www.youjiaxiaodian.com/api/sellerreg" title:@"" toolbar:NO];
    MSJoinViewController *controller = [[MSJoinViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionFunction:(NSString *)url
{
    [self showWating:nil];
    [[MSSystem sharedInstance] checkVersion:^{
        if ( [MSSystem sharedInstance].version.auth == 1 )
        {
            [self dismissWating];
            MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:url title:nil toolbar:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [[ClientAgent sharedInstance] auth:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                [self dismissWating];
                if ( error == nil )
                {
                    MSUIAuthWebViewController *controller = [[MSUIAuthWebViewController alloc] init];
                    controller.htmlStr = data;
                    [controller setCallback:^(bool state ) {
                        [self.navigationController popViewControllerAnimated:NO];
                        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:url title:nil toolbar:YES];
                        [self.navigationController pushViewController:controller animated:YES];
                    }];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }];
        }
    }];
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

- (void)actionForClearCache
{
    [MSSystem clearCache];
    [self showMessageInfo:@"缓存已清除" delay:2];
}
- (void)actionForSeller
{
     MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:@"http://www.youjiaxiaodian.com/api/sellerreg" title:@"" toolbar:NO];
    controller.defaultBackButton = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)actionForRecommend
{
    UMTableViewController *controller = [[UMTableViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
    [[ClientAgent sharedInstance] getpushsound:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            self.pushOn = [@"1" isEqualToString:data];
            [self.uiSwitch setOn:self.pushOn animated:YES];
        }
    }];
}

- (void)actionPushSwitch:(UISwitch*)sender
{
    __PSELF__;
    [[ClientAgent sharedInstance] setpushsound:sender.isOn?1:0 block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error!=nil){
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)actionForReg
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionForLogout
{
    [MSSystem logout];
    [self initData];
    [self.tableView reloadData];
}

@end
