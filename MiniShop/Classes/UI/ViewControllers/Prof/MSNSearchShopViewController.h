/**
* *********************************************************
*  MSNSearchShopViewController.h
*
*  MiniShop
*
*  Created by Wuquancheng on 13-12-28.
*  Copyright (c) 2013年 mini. All rights reserved.
*
* *********************************************************
*/

#import "MSViewController.h"

@class MSNWellCate;

@interface MSNSearchShopViewController : MSViewController
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) MSNWellCate *cate;
@end
