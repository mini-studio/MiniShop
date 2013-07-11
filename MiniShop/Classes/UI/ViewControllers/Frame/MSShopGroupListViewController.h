//
//  MSImportFavViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-9.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"

enum {
    EImportFav,
    ESearch,
    ESearchInCategory
};

@interface MSShopGroupListViewController : MSViewController
@property (nonatomic,strong) id favData;
@property (nonatomic) int type;
@property (nonatomic,strong) NSString *key;
@end

