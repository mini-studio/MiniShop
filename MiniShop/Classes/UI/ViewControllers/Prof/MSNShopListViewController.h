//
//  MSNShopListViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 14-2-9.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSViewController.h"

@class MSNShopList;

@interface MSNShopListViewController : MSViewController
@property (nonatomic,strong)EGOUITableView   *tableView;
@property (nonatomic,strong) NSString *cTitle;

- (void)receiveData:(MSNShopList *)data page:(int)page;
@end
