//
//  MSSystem.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSSystem.h"
#import "MSImageInfo.h"
#import "MSNotiItemInfo.h"
#import "MSDetailViewController.h"
#import "MiniNSURLProtocol.h"
#import "MiniURLCache.h"
#import "MiniFileUtil.h"
#import "SDImageCache.h"

@interface MSSystem()
@property (nonatomic, strong) NSDate *lastCheckUpdate;
@end

@implementation MSSystem
@synthesize authForImportFav = _authForImportFav;

SYNTHESIZE_MINI_ARC_SINGLETON_FOR_CLASS(MSSystem)

- (id)init
{
    if ( self = [super init] )
    {
        self.user = [[MSUser alloc] init];
        self.version = [[MSVersion alloc] init];
        self.lastCheckUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastCheckUpdate"];
    }
    return self;
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
        [[ClientAgent sharedInstance] version:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                self.lastCheckUpdate = [NSDate date];
                self.version = data;
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
}

+ (NSString *)bundleversion
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return version;
}

- (void)didBecomeActive
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[ClientAgent sharedInstance] image:@"bg" block:^(NSError *error, MSImageInfo* data, id userInfo, BOOL cache) {
            if ( error == nil && data.key != nil )
            {
                NSString *key = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_BG_IMAGE"];
                if ( key == nil || ![data.key isEqualToString:key] )
                {
                    [self loadImge:data.url key:@"MS_BG_IMAGE" imagekey:data.key];
                }
            }
            
        }];
        [[ClientAgent sharedInstance] image:@"start" block:^(NSError *error, MSImageInfo* data, id userInfo, BOOL cache) {
            if ( error == nil && data.key != nil )
            {
                NSString *key = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_START_IMAGE"];
                if ( key == nil || ![data.key isEqualToString:key] )
                {
                    [self loadImge:data.url key:@"MS_START_IMAGE" imagekey:data.key];
                }
            }
        }];
        
        NSString *fpath = [ClientAgent filePathForKey:@"ms_count_queryOrderDetail"];
        NSData *data = [NSData dataWithContentsOfFile:fpath];
        if ( data != nil )
        {
            [[ClientAgent sharedInstance] countlist:data userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            }];
        }
        [self checkVersion:^{} force:YES];
    });
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
        if ( msg != nil )
        {
            NSString *type = [msg valueForKey:@"type"];
            NSInteger mid = [[msg valueForKey:@"id"] integerValue];
            NSInteger shopId = [[msg valueForKey:@"shop_id"] integerValue];
            MSNotiItemInfo *itemInfo = [[MSNotiItemInfo alloc] init];
            itemInfo.type = type;
            itemInfo.mid = mid;
            itemInfo.shop_id = shopId;
            MSDetailViewController *controller = [[MSDetailViewController alloc] init];
            controller.itemInfo = itemInfo;
            controller.from = @"push";
            [naviController pushViewController:controller animated:YES];
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

@end
