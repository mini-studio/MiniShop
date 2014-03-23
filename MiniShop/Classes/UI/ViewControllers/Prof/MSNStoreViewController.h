//
//  MSNStoreViewController.h
//  MiniShop
//  我的商城
//  Created by Wuquancheng on 13-11-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSFrameViewController.h"

#import "UIColor+Mini.h"
#import "UITableViewCell+GroupBackGround.h"
#import "EGOUITableView.h"
#import "MSUIWebViewController.h"
#import "NSString+Mini.h"
#import "NSString+URLEncoding.h"
#import "MSUIMoreDataCell.h"
#import "MiniUISegmentView.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MRLoginViewController.h"
#import "KeychainItemWrapper.h"
#import "MSNGoodListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MSNStoreViewController : MSFrameViewController
@end

@interface MSNStoreContentViewController : MSNGoodListViewController
@property (nonatomic) NSString*tagId;
@property (nonatomic,strong)NSString *orderBy;
@end