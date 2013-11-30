//
//  MyStoreViewController.h
//  MiniShop
//  我的商城
//  Created by Wuquancheng on 13-11-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSFrameViewController.h"

#import "MSNofiViewController.h"
#import "UIColor+Mini.h"
#import "MSNotify.h"
#import "MSNotiItemInfo.h"
#import "MSNotiTableCell.h"
#import "UITableViewCell+GroupBackGround.h"
#import "MSItemListViewController.h"
#import "EGOUITableView.h"
#import "MSUIWebViewController.h"
#import "MSDetailViewController.h"
#import "NSString+Mini.h"
#import "NSString+URLEncoding.h"
#import "MSUIMoreDataCell.h"
#import "MiniUISegmentView.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MSShopGroupListViewController.h"
#import "MSPotentialViewController.h"
#import "MRLoginViewController.h"
#import "MSShopGalleryViewController.h"
#import "KeychainItemWrapper.h"
#import <QuartzCore/QuartzCore.h>

@interface MyStoreViewController : MSFrameViewController
@end

@class MSNotify;
@class MiniUISegmentView;
@interface MyStoreContentViewController : MSViewController
@property (nonatomic) NSInteger mid;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *topicDataSource;
@property (nonatomic)BOOL mark;
- (void)receiveData:(MSNotify *)noti page:(int)page type:(int)type;
- (void)refreshData;
@end