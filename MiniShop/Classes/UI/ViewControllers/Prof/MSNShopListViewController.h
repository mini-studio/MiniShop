//
//  MSNShopListViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 14-2-9.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSViewController.h"

@class MSNShopList;

typedef enum {
    EFavorite,
    EGroupShop
}
SHOP_LIST_TYPE;


@interface MSNShopListViewController : MSViewController
@property (nonatomic, strong)EGOUITableView   *tableView;
@property (nonatomic, strong) NSString *cTitle;
@property (nonatomic, strong) NSString *ids;
@property (nonatomic) SHOP_LIST_TYPE listType;

- (void)receiveData:(MSNShopList *)data page:(int)page;
@end
