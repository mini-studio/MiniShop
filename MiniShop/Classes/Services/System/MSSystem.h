//
//  MSSystem.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiniSingletonFactory.h"
#import "MSUser.h"
#import "MSVersion.h"

#define MSNotificationReceiveRemote @"MSNotificationReceiveRemote"

@interface MSSystem : NSObject
@property (nonatomic,strong) MSUser *user;
@property (nonatomic) int   authForImportFav;
@property (nonatomic,strong) MSVersion *version;
@property (nonatomic,strong) NSString *deviceToken;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MSSystem)

- (void)checkVersion:(void (^)())block;

- (void)initSystem;

+ (NSString *)bundleversion;

- (void)didBecomeActive;

+ (UIImage *)loadStartImage;
+ (UIImage *)loadBgImage;

+ (void)localNotification;
+ (void)didReceiveRemoteNotification:(id)userInfo currentNaviController:(UINavigationController*)naviController;

+ (BOOL)isFirstRun;
+ (void)clearFirstRun;

+ (void)clearCache;


@end
