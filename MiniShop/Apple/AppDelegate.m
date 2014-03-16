//
//  AppDelegate.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"

#import "MSGuideViewController.h"
#import "MSMainTabViewController.h"
#import "MSSystem.h"
#import "MRLoginViewController.h"
#import "MSMiniUINavigationController.h"
#import "NSString+Mini.h"
#import <safeudid/SafeDevice.h>

//NSString* const appIDForWeiXin = @"wx5267b1263ded2fbd";
//NSString* const appKeyForWeiXin = @"1f9e057184c7e9b458e2b4c336a1bff5";

NSString* const appIDForWeiXin = @"wx5267b1263ded2fbd";
NSString* const appKeyForWeiXin = @"1f9e057184c7e9b458e2b4c336a1bff5";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    SafeDevice *device = [SafeDevice build];
    NSLog(@"%@",[device deviceInfo]);
    MSSystem *system = [MSSystem sharedInstance];
    [system initSystem];
    self.isFirstRun = [MSSystem isFirstRun];
    if (  self.isFirstRun )
    {
        [UIApplication sharedApplication].statusBarHidden = YES;
        self.viewController = [[MSGuideViewController alloc] init];
        self.window.rootViewController = self.viewController;
    }
    else
    {
        [self loadMainController];
    }

    [[UIApplication sharedApplication]  registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_image"]];
//    [self.window addSubview:imageView];
    [self.window makeKeyAndVisible];
    [self umengTrack];
    [self handleRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] application:application];
    
    
    [self clearBadge:application];
    
    [WXApi registerApp:appIDForWeiXin];
    return YES;
}

- (void)loadMainController
{
    [self loadMainController:NO];
}

- (void)loadMainController:(BOOL)mustLogin
{
    [UIApplication sharedApplication].statusBarHidden = NO;
//    if ( (WHO == nil && (mustLogin || MAIN_VERSION >= 7)) || self.isFirstRun ) {
//        MRLoginViewController *controller = [[MRLoginViewController alloc] init];
//        MSMiniUINavigationController *navi = [[MSMiniUINavigationController alloc] initWithRootViewController:controller];
//        self.viewController = navi;
//        self.window.rootViewController = navi;
//    }
//    else {
        self.viewController = [[MSMainTabViewController alloc] init];
        self.window.rootViewController = self.viewController;
//    }

}


- (void)applicationWillResignActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)onlineConfigCallBack:(NSNotification *)notification
{
    LOG_DEBUG(@"online config has fininshed and params = %@", notification.userInfo);
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
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

-(void) onReq:(BaseReq*)req
{
    NSString *path = nil;
    NSString *extInfo = nil;
    if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        WXAppExtendObject *obj = msg.mediaObject;
        path = obj.url;
        extInfo = obj.extInfo;
    }
    if ( path.length == 0 ) {
        return;
    }
    CGFloat delay = 1.0;
    if (UIApplicationStateActive == [UIApplication sharedApplication].applicationState)
    {
        delay = 0;
    }
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ( path.length > 0 )
        {
            NSString *prefix = @"youjiaxiaodian://shop"; //关注此店铺
            if ( [path hasPrefix:prefix])
            {
                NSString *shopId = [path substringFromIndex:prefix.length];
                if ( shopId.length > 0 )
                {
                   
                }
            }
            else if ( [path hasPrefix:@"youjiaxiaodian://good/"] ) //跳转详情页
            {
//                NSString *goodId = [path substringFromIndex:@"youjiaxiaodian://good/".length];
//                [[ClientAgent sharedInstance] singlegoodsdetail:goodId.longLongValue from:@"list" block:^(NSError *error, MSGoodsList* data, id userInfo, BOOL cache) {
//                    if (error==nil)
//                    {
//                        MSDetailViewController *c = [[MSDetailViewController alloc] init];
//                        c.mtitle = @"";
//                        c.from = @"list";
//                        c.goods = data;
//                        [[self currentNaviController] pushViewController:c animated:YES];
//                    }
//                }];
            }
            else if ( [path hasPrefix:@"youjiaxiaodian://mshopnews/"] )
            {
//                NSString *shopIds =[path substringFromIndex:@"youjiaxiaodian://mshopnews/".length];
//                MSShopNewsViewController *controller = [[MSShopNewsViewController alloc] init];
//                controller.shopIds = shopIds;
//                [[self currentNaviController] pushViewController:controller animated:YES];
            }
            else if ( [path hasPrefix:@"http://youjiaxiaodian.com/share?type=share_shop&id="] ){
//                NSString *shopIds =[path substringFromIndex:@"http://youjiaxiaodian.com/share?type=share_shop&id=".length];
//                if ( shopIds.length > 0 ) {
//                    MSShopNewsViewController *controller = [[MSShopNewsViewController alloc] init];
//                    controller.shopIds = shopIds;
//                    [[self currentNaviController] pushViewController:controller animated:YES];
//                }
            }
        }
    });
}
-(void) onResp:(BaseResp*)resp
{
    
}

@end
