//
//  MSNEspecialIndexViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSFrameViewController.h"
#import "UIColor+Mini.h"
#import "UITableViewCell+GroupBackGround.h"
#import "EGOUITableView.h"
#import "MSUIWebViewController.h"
#import "NSString+Mini.h"
#import "NSString+URLEncoding.h"
#import "MSUIMoreDataCell.h"
#import "MiniUISegmentView.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MRLoginViewController.h"
#import "MSNCate.h"

@interface MSNEspecialIndexViewController : MSFrameViewController

@end


@interface MSNEspecialContentViewController: MSViewController
@property (nonatomic,strong)MSNSpecialcate *cate;
@end