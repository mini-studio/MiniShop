//
//  EspecialIndexViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

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

@interface EspecialIndexViewController : MSFrameViewController

@end


@interface EspecialContentViewController: MSViewController
@property (nonatomic) NSInteger mid;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *topicDataSource;
@property (nonatomic)BOOL mark;
- (void)receiveData:(MSNotify *)noti page:(int)page type:(int)type;
- (void)refreshData;
- (void)selectedAsChild;
@end