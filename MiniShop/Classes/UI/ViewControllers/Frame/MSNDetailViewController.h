//
//  MSNDetailViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MWPhotoBrowser.h"

@interface MSNDetailViewController : MSViewController
@property (nonatomic,strong)NSArray  *items;
@property (nonatomic,strong)NSString *from;
@property (nonatomic)NSInteger defaultIndex;
@property (nonatomic,strong)NSString *mtitle;
@end
