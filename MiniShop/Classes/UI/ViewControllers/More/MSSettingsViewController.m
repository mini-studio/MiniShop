//
//  MSFbViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSSettingsViewController.h"
#import "UMFeedbackViewController.h"
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
#import "UMFeedback.h"
#import "MSJoinViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

// 间距配置
#define KCopyrightHeight            62.0f

// 字体颜色配置
#define KLabelColor          0x898989AA

// 字体高度配置
#define KLabelHeight          12.0f

@interface MSSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSDictionary *dictionary;
@property (nonatomic,strong)UMFeedback *umFeedback;
@end

@implementation MSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dictionary = @{@"0":@[
                                    @{@"action":@"actionForInvote",@"text":@"小主，跪求评分"}
                                    ],
                            @"1":@[
                                    @{@"action":@"actionForFeedback",@"text":@"来聊聊您的想法"},
                                    @{@"action":@"actionForJoin",@"text":@"加入QQ群"},
                                    @{@"action":@"actionForSeller",@"text":@"卖家管理"},
                                    @{@"action":@"actionForClearCache",@"text":@"清除缓存"}
                                    ],
                            @"2":@[
                                    @{@"action":@"actionForAbout",@"text":@"关于"}
                                  ]
                            };
    }
    return self;
}

- (void)dealloc
{
    _umFeedback.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"更多";    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,20 )];
    header.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableHeaderView = header;
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
    }
    NSArray *dataSource = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xebebebff] sectionRowNumbers:dataSource.count];
    id data = [dataSource objectAtIndex:indexPath.row];
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

@end
