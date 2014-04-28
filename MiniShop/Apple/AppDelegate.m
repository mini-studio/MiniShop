//
//  AppDelegate.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "UMSocial.h"

#import "MSGuideViewController.h"
#import "MSMainTabViewController.h"
#import "MSSystem.h"

#import "UMSocialYixinHandler.h"
#import "UMSocialFacebookHandler.h"
#import "UMSocialLaiwangHandler.h"
#import "UMSocialWechatHandler.h"

#import <TencentOpenAPI/QQApiInterface.h>       //手机QQ SDK
#import <TencentOpenAPI/TencentOAuth.h>

#import "MSNShopDetailViewController.h"

#import "MSDefine.h"
#import "MSNGoodsList.h"

#import "MSNDetailViewController.h"
#import "MSNShopListViewController.h"

#import "NSString+mini.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    MSSystem *system = [MSSystem sharedInstance];
    [system initSystem];
    self.isFirstRun = [MSSystem isFirstRun];
//    if (  self.isFirstRun )
//    {
//        [UIApplication sharedApplication].statusBarHidden = YES;
//        self.viewController = [[MSGuideViewController alloc] init];
//        self.window.rootViewController = self.viewController;
//    }
//    else
//    {
        [self loadMainController];
//    }

    [[UIApplication sharedApplication]  registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [self.window makeKeyAndVisible];
    [self umengTrack];
    [self umengSocia];
    [self handleRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] application:application];
    
    [self clearBadge:application];
    [MSSystem clearFirstRun];
    return YES;
}

- (void)loadMainController
{
    [self loadMainController:NO];
}

- (void)loadMainController:(BOOL)mustLogin
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.viewController = [[MSMainTabViewController alloc] init];
    self.window.rootViewController = self.viewController;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *key = @"LAST_CLEAR_CACHE";
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval time = [def doubleForKey:key];
    if ( time == 0 )
    {
        time = current;
        [def setDouble:time forKey:key];
    }
    if ( current - time > 3*3600 )
    {
        [MSSystem clearCache];
        [def setDouble:current forKey:key];
    }
    [def synchronize];
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSDate *now=[NSDate new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear|kCFCalendarUnitMonth | kCFCalendarUnitDay| kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond) fromDate:now];
    NSInteger hour = [components hour];
    if ( hour < 20 ) {
        components.hour = 20;
    }
    else {
        now=[NSDate dateWithTimeIntervalSinceNow:24*3600];
        components = [calendar components:(kCFCalendarUnitEra | kCFCalendarUnitYear|kCFCalendarUnitMonth | kCFCalendarUnitDay| kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond) fromDate:now];
        components.hour = 20;
    }
    components.second = 0;
    components.minute = 0;
    NSDate *fireDate  = [calendar dateFromComponents:components];
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        notification.fireDate=fireDate;
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication]  scheduleLocalNotification:notification];
    }
    
    //[MSSystem localNotification];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[MSSystem sharedInstance] didBecomeActive];
    [self clearBadge:application];
    //[UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)onlineConfigCallBack:(NSNotification *)notification
{
    LOG_DEBUG(@"online config has fininshed and params = %@", notification.userInfo);
}

- (void)umengSocia
{
    NSString *url = [ClientAgent host];
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UM_KEY];
    
    //    //打开Qzone的SSO开关
    [UMSocialConfig setSupportQzoneSSO:YES importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    
    //打开新浪微博的SSO开关
    [UMSocialConfig setSupportSinaSSO:YES];
    
    //设置微信AppId，url地址传nil，将默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:APP_ID_FOR_WEIXIN url:url];
    
    //设置手机QQ的AppId，指定你的分享url，若传nil，将使用友盟的网址
    [UMSocialConfig setQQAppId:APP_ID_FOR_QQ url:url importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    
    [UMSocialConfig setShareQzoneWithQQSDK:YES url:url importClasses:@[[QQApiInterface class],[TencentOAuth class]]];

}

- (void)umengTrack
{

    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    //    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    //    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UM_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:userInfo application:application];
}

- (void)clearBadge:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    NSArray* scheduledNotifications = [NSArray arrayWithArray:application.scheduledLocalNotifications];
    application.scheduledLocalNotifications = scheduledNotifications;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self handleRemoteNotification:notification.userInfo application:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	//NSUInteger pushType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if ( deviceToken == nil )
    {
        LOG_ERROR(@"%@", @"device token is nil");
        return;
    }
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];    
	[MSSystem sharedInstance].deviceToken = token;
    [[ClientAgent sharedInstance] uploadToken:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
        LOG_DEBUG(@"%@",data);
    }];
	LOG_DEBUG(@"deviceToken: %@",token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#ifdef DEBUG
	NSString *status = [NSString stringWithFormat:@"%@\nRegistration failed.\n\nError: %@", [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
                        @"Notifications were active for this application" :
                        @"Remote notifications were not active for this application", [error localizedDescription]];
    LOG_ERROR(@"Error in registration. Error: %@", error);
	LOG_ERROR(@"status = %@",status);
#endif
    //   [[HaloUIManager sharedInstance] showWarningView:status warning:YES];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo application:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (UIApplicationStateActive == [UIApplication sharedApplication].applicationState)
    {
        NSDictionary *apsDic = [userInfo objectForKey:@"aps"];
        NSString *alertStr =[apsDic objectForKey:@"alert"];
        if (alertStr != nil && alertStr.length)
        {
            [MiniUIAlertView showAlertWithTitle:@"有家小店" message:alertStr block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
                if ( buttonIndex != alertView.cancelButtonIndex )
                {
                    [MSSystem didReceiveRemoteNotification:userInfo currentNaviController:[self currentNaviController]];
                }
            } cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
        }
    }
    else
    {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MSSystem didReceiveRemoteNotification:userInfo currentNaviController:[self currentNaviController]];
        });
    }
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         [MobClick event:MOB_ACTIVE_BY_PUSH];
    });
}

- (UINavigationController *)currentNaviController
{
    if ( [self.viewController isKindOfClass:[MSMainTabViewController class]])
    {
        UIViewController *c = [(MSMainTabViewController*)self.viewController selectedViewController];
        if ( c != nil )
        {
            if ( [c isKindOfClass:[UINavigationController class]] )
            {
                return (UINavigationController*)c;
            }
            else
            {
                return c.navigationController;
            }
        }
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.absoluteString hasPrefix:@"QQ"]) {
        return [self handleQQOpenURL:url sourceApplication:nil annotation:nil];
    }
    else {
        return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:self];
    }
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.absoluteString hasPrefix:@"QQ"]) {
        return [self handleQQOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    //else if ([url.absoluteString hasPrefix:@"wx"]) {
        return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:self];
//    }
//    else {
//        return YES;
//    }
}

- (BOOL)handleQQOpenURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    QQApiMessage* msg = [QQApi handleOpenURL:url];
    QQApiObject* apiObj = msg.object;
    if([apiObj isKindOfClass:[QQApiURLObject class]])
    {
        QQApiURLObject* obj = (QQApiURLObject*)apiObj;
        NSString *str = obj.url.absoluteString;
        [self handleOpenUrl:str extInfo:nil];
    }
    return YES;
}


- (void)onReq:(BaseReq*)req
{
    NSString *path = nil;
    NSString *extInfo = nil;
    if([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        WXAppExtendObject *obj = msg.mediaObject;
        path = obj.url;
        extInfo = obj.extInfo;
    }
    if ( path.length == 0 ) {
        return;
    }
    [self handleOpenUrl:path extInfo:extInfo];
}

- (void)handleOpenUrl:(NSString*)requestUrl extInfo:(NSString*)extInfo
{
    CGFloat delay = 1.0;
    if (UIApplicationStateActive == [UIApplication sharedApplication].applicationState) {
        delay = 0;
    }
    NSURL *url = [NSURL URLWithString:requestUrl];
    NSString * path = [url path];
    NSString *query = [url query];
    NSArray *array = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *item in array) {
        NSRange rang = [item rangeOfString:@"="];
        if (rang.location != NSNotFound) {
            NSString *key = [item substringToIndex:rang.location];
            NSString *value = [item substringFromIndex:rang.location+1];
            params[key] = value;
        }
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ( path.length > 0 ) {
            if ([@"/new/share" isEqualToString:path]) {
                NSString *m = params[@"m"];
                if ([@"goods" isEqualToString:m]) {
                    if (extInfo!=nil) {
                        NSData *data = [extInfo dataUsingEncoding:NSUTF8StringEncoding];
                        NSJSONSerialization *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingMutableContainers error:nil];
                        if (jsonData!=nil) {
                            MSNGoodsItem *item = [[MSNGoodsItem alloc] init];
                            [item convertWithJson:jsonData];
                            MSNDetailViewController *controller = [[MSNDetailViewController alloc] init];
                            controller.items = @[item];
                            [[self currentNaviController] pushViewController:controller animated:YES];

                        }
                    }
                    else {
                        NSString *goodsId = params[@"id"];
                        MSNDetailViewController *controller = [[MSNDetailViewController alloc] init];
                        controller.goodsId = goodsId;
                        [[self currentNaviController] pushViewController:controller animated:YES];
                    }
                }
                else if ([@"share_shop" isEqualToString:m]) {
                    NSString *ids = params[@"ids"];
                    NSArray *items = [ids componentsSeparatedByString:@","];
                    if (items.count==1) {
                        MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
                        MSNShopInfo *shopInfo = [[MSNShopInfo alloc] init];
                        shopInfo.shop_id = ids;
                        controller.shopInfo = shopInfo;
                        [[self currentNaviController] pushViewController:controller animated:YES];
                    }
                    else {
                        MSNShopListViewController *controller = [[MSNShopListViewController alloc] init];
                        controller.ids = ids;
                        controller.listType = EGroupShop;
                        controller.cTitle = @"好友分享的商店";
                        [[self currentNaviController] pushViewController:controller animated:YES];
                    }
                }
            }
        }
    });
}


@end
