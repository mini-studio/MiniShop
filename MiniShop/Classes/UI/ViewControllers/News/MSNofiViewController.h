//
//  MSMessViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniViewController.h"

@class MSNotify;
@class MiniUISegmentView;

@interface MSNofiViewController : MSViewController
@property (nonatomic,strong) MiniUISegmentView *segment;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *topicDataSource;
@property (nonatomic)BOOL mark;
- (void)receiveData:(MSNotify *)noti page:(int)page type:(int)type;
- (void)refreshData;

@end
