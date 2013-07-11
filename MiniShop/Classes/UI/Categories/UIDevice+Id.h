//
//  UIDevice+Id.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UDID ([UIDevice currentDevice].uniqueGlobalDeviceIdentifier)
//#define UDID @"e385490e1da030bdb0c16eb6942a26c4"
#define NICK @""

@interface UIDevice (Id)

- (NSString *) uniqueDeviceIdentifier;

- (NSString *) uniqueGlobalDeviceIdentifier;

@end
