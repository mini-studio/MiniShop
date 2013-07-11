//
//  MSDetailViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MWPhotoBrowser.h"
#import "MSNotiItemInfo.h"
#import "MSGoodsList.h"
@interface MSDetailViewController : MWPhotoBrowser
@property (nonatomic,strong)MSNotiItemInfo *itemInfo;
@property (nonatomic,strong)MSGoodsList     *goods; //数据源,body_info为实体
@property (nonatomic,strong)NSString        *from;
@property (nonatomic)BOOL more;
@property (nonatomic)NSInteger defaultIndex;
@property (nonatomic,strong)NSString *mtitle;
@end
