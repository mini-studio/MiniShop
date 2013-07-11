//
//  AppDelegate.h
//  MiniShop
// <string>Icon.png</string>
// <string>Icon@2x.png</string>
// <string>Icon-Small.png</string>
// <string>Icon-Small@2x.png</string>
// <string>Icon-72.png</string>
//
//  Created by Wuquancheng on 13-3-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

- (void)loadMainController;

- (UINavigationController *)currentNaviController;

@end
