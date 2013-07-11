//
//  MSShopListViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"

enum MSListType
{
   ERecommend,
   EFollowed
};

@interface MSShopListViewController : MSViewController

@property (nonatomic) int type;

@end
