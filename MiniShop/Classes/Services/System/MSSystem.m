//
//  MSSystem.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSSystem.h"
#import "MiniNSURLProtocol.h"
#import "MiniURLCache.h"
#import "MiniFileUtil.h"
#import "SDImageCache.h"
#import "NSUserDefaults+Mini.h"
#import "UIDevice+Ext.h"
#import "NSUserDefaults+Mini.h"
#import "KeychainItemWrapper.h"
#import "MSNDetailViewController.h"
#import "MSNShopDetailViewController.h"
#import "MSNGoodsList.h"


@interface MSSystem()
@property (nonatomic, strong) NSDate *lastCheckUpdate;
@end

@implementation MSSystem
@synthesize udid = _udid;
@synthesize authForImportFav = _authForImportFav;

SYNTHESIZE_MINI_ARC_SINGLETON_FOR_CLASS(MSSystem)

- (id)init
{
    if ( self = [super init] )
    {
        self.version = [[MSVersion alloc] init];
        self.lastCheckUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastCheckUpdate"];
        _mainVersion = [UIDevice iosMainVersion];
        NSDictionary *navbarTitleTextAttributes = [UINavigationBar appearance].titleTextAttributes;
        if ( navbarTitleTextAttributes == nil ) {
             navbarTitleTextAttributes = @{UITextAttributeTextColor:[UIColor whiteColor]};
        }
        else {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:navbarTitleTextAttributes];
            [dic setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
            navbarTitleTextAttributes = dic;
        }
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        _appStoreUrl = @"http://itunes.apple.com/app/id617697319?mt=8";
    }
    return self;
}

- (void)setUser:(MSUser *)user
{
    [self setUser:user checkVersion:YES];
}

- (void)setUser:(MSUser *)user checkVersion:(BOOL)checkVersion
{
    _user = user;
    if ( _user != nil ) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setMiniObject:user forkey:@"MS_SYS_USER"];
        [[ClientAgent sharedInstance] uploadToken:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            LOG_DEBUG(@"%@",data);
        }];
        if ( checkVersion )
        [self checkVersion:^{
            
        } force:YES];
    }
    else {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def removeObjectForKey:@"MS_SYS_USER"];
        [def removeObjectForKey:@"showImportTaobaoView"];
        [def synchronize];
    }
}

- (NSString *)udid
{
    if ( _udid == nil ) {
        KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number" accessGroup:nil];
        NSString *udid = (NSString*)[keychainWrapper objectForKey:(__bridge id)kSecValueData];
        if ( udid.length > 0 ) {
            _udid = udid;
        }
    }
    return _udid;
}

- (void)setUdid:(id)udid
{
    if ( [udid isKindOfClass:[NSNumber class]] ) {
        _udid = [NSString stringWithFormat:@"%lld",[(NSNumber*)udid longLongValue]];
    }
    else {
        _udid = udid;
    }
    if ( _udid.length > 0 ) {
        KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number" accessGroup:nil];
        [keychainWrapper setObject:udid forKey:(__bridge id)kSecValueData];
        _udid = udid;
    }
}

- (MSUser*)loadUser
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    MSUser *user = (MSUser*)[def miniObjectValueForKey:@"MS_SYS_USER"];
    if (user.usernick.length>0) {
        return user;
    }
    else {
        return nil;
    }
}

- (void)setAuthForImportFav:(int)authForImportFav
{
    _authForImportFav = authForImportFav;
    if ( _authForImportFav == 1 )
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"MS_authForImportFav_date"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MS_authForImportFav_date"];
    }
}

- (int)authForImportFav
{
    if ( _authForImportFav == 0 )
    {
        NSDate *date = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_authForImportFav_date"];
        if ( date != nil && [date isKindOfClass:[NSDate class]] && [date timeIntervalSinceNow] > -24*3600 )
        {
            return 1;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MS_authForImportFav_date"];
        }
    }
    return _authForImportFav;
}

- (void)checkVersion:(void (^)())block
{
    [self checkVersion:block force:NO];
}

- (void)checkVersion:(void (^)())block  force:(BOOL)force
{
    if ( self.lastCheckUpdate == nil || force || [self.lastCheckUpdate  timeIntervalSinceNow] < -24*3600 )
    {
        [[ClientAgent sharedInstance] version:nil block:^(NSError *error, MSVersion* data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                if ( data.user_nick.length > 0 ) {
                MSUser *user = [[MSUser alloc] init];
                user.usernick = data.user_nick;
                user.uniqid = data.uniqid;
                user.imei = data.imei;
                [self setUser:user checkVersion:NO];
                }
                self.lastCheckUpdate = [NSDate date];
                self.version = data;
                if ( self.version.imei.length > 0) {
                    self.udid = self.version.imei;
                }
                if ( self.version.type == 2 )
                {
                    [MiniUIAlertView showAlertWithTitle:@"升级提示" message:self.version.intro block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
                        if ( buttonIndex != alertView.cancelButtonIndex )
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.version.url]];
                        }
                        else
                        {
                            exit(0);
                        }
                    } cancelButtonTitle:@"退出" otherButtonTitles:@"升级", nil];
                }
                else if ( self.version.type == 1 ) //检查上次提示时间，超过2天再给予提示
                {
                    NSString *lastv = [[NSUserDefaults standardUserDefaults] valueForKey:@"cversion"];
                    NSDate *lastPrompt = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastCheckUpdatePrompt"];
                    if ( lastv == nil || ![lastv isEqualToString:self.version.v] || (lastPrompt == nil || [lastPrompt  timeIntervalSinceNow] < -72*3600) )
                    {
                        [MiniUIAlertView showAlertWithTitle:@"升级提示" message:self.version.intro block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
                            if ( buttonIndex != alertView.cancelButtonIndex )
                            {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.version.url]];
                            }
                        }cancelButtonTitle:@"取消" otherButtonTitles:@"升级", nil];
                        [[NSUserDefaults standardUserDefaults] setValue:self.lastCheckUpdate forKey:@"lastCheckUpdatePrompt"];
                    }
                }
                [[NSUserDefaults standardUserDefaults] setValue:self.version.v forKey:@"cversion"];
                [[NSUserDefaults standardUserDefaults] setValue:self.lastCheckUpdate forKey:@"lastCheckUpdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:MN_NOTI_RECEIVE_VERSION object:nil];
            }
            if ( block )
            {
                block();
            }
        }];
    }
    else if ( block )
    {
        block();
    }
}

- (void)initSystem
{
    [NSURLProtocol registerClass:[MiniNSURLProtocol class]];
    MiniURLCache *cache = [MiniURLCache sharedCache];
    [NSURLCache setSharedURLCache:cache];
    
    MSUser *user = [self loadUser];
    if ( user != nil ) {
        _user = user;
        double delayInSeconds = 20.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[ClientAgent sharedInstance] uploadToken:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                LOG_DEBUG(@"%@",data);
            }];
        });
    }
}

+ (NSString *)bundleVersion
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return version;
}

- (void)didBecomeActive
{
    [self invote];
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self checkVersion:^{}];
    });
}

- (void)invote
{
    NSString *key = [NSString stringWithFormat:@"invote_%@", [MSSystem bundleVersion]];
    dispatch_block_t __block__ = ^{
        [MiniUIAlertView showAlertWithTitle:@"别忘了,您有给我们打分的权力" message:@"亲,这一版,好用吗? 你的鼓励对我们十分重要！满心期待你的评语~" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setSyncValue:[NSNumber numberWithLong:-1] forKey:key];
                NSURL *url = [NSURL URLWithString:_appStoreUrl];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }cancelButtonTitle:@"放弃权力" otherButtonTitles:@"赐下好评",nil];
    };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastTime = [defaults valueForKey:key];
    if ( lastTime == nil ) {
        lastTime = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]-24*3600*4+180];
        [defaults setSyncValue:lastTime forKey:key];
    }
    else {
        if ( lastTime.longValue > 0 ) {
            long currentTime = [[NSDate date] timeIntervalSince1970];
            if ( currentTime-lastTime.longValue > 24*3600*4) {
                lastTime = [NSNumber numberWithLong:currentTime];
                [defaults setSyncValue:lastTime forKey:key];
                __block__();
            }
        }
    }
}

- (void)loadImge:(NSString *)url key:(NSString *)key imagekey:(NSString *)imagekey
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if ( data != nil )
        {
            UIImage *image = [UIImage imageWithData:data];
            if ( image != nil )
            {
                [[NSUserDefaults standardUserDefaults] setValue:imagekey forKey:key];
                NSString *fpath = [ClientAgent filePathForKey:key];
                [data writeToFile:fpath atomically:YES];
            }
        }
    });
}

+ (UIImage *)loadStartImage
{
    NSString *fpath = [ClientAgent filePathForKey:@"MS_START_IMAGE"];
    UIImage *image = [UIImage imageWithContentsOfFile:fpath];
    return image;
}

+ (UIImage *)loadBgImage
{
    NSString *fpath = [ClientAgent filePathForKey:@"MS_BG_IMAGE"];
    UIImage *image = [UIImage imageWithContentsOfFile:fpath];
    return image;
}

+ (void)localNotification
{
}

+ (void)didReceiveRemoteNotification:(id)userInfo currentNaviController:(UINavigationController*)naviController
{
    if ( userInfo != nil && naviController != nil )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MSNotificationReceiveRemote object:nil];
        id msg = [userInfo valueForKey:@"msg"];
        if ( msg != nil ) {
            NSString * goodsId = [msg valueForKey:@"goods_id"];
            if (goodsId!=nil && goodsId.length>0) {
                MSNDetailViewController *controller = [[MSNDetailViewController alloc] init];
                controller.goodsId = goodsId;
                [naviController pushViewController:controller animated:YES];
            }
            else {
                NSString * shopId = [msg valueForKey:@"shop_id"];
                if (shopId!=nil && shopId.length>0) {
                    MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
                    MSNShopInfo *shopInfo = [[MSNShopInfo alloc] init];
                    shopInfo.shop_id = shopId;
                    controller.shopInfo = shopInfo;
                    [naviController pushViewController:controller animated:YES];
                }
                else {
                    [MiniUIAlertView showAlertTipWithTitle:@"好店汇" message:@"not found shop info" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {}];
                }
            }
        }
    }
}

+ (BOOL)isFirstRun
{
    NSString * f = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstRun"];
    return (f==nil);
}

+ (void)clearFirstRun
{
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"firstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearCache
{
    [ClientAgent clearCache];
    [[SDImageCache sharedImageCache] clearDisk];
}

+ (void)logout
{
    WHO = nil;
    [ClientAgent clearCache];
}

@end
