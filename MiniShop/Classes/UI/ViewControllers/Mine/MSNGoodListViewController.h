//
//  MSNGoodListViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSNGoodsList.h"

@interface MSNGoodListViewController : MSViewController
@property (nonatomic,strong) EGOUITableView *tableView;
@property (nonatomic)BOOL mark;
@property (nonatomic,strong)MSNGoodsList *dataSource;
@property (nonatomic)NSInteger page;
@property (nonatomic)BOOL showNaviView;
- (void)refreshData;
- (NSArray*)allGoodItems;
- (void)receiveData:(MSNGoodsList*)data page:(int)page;
@end
