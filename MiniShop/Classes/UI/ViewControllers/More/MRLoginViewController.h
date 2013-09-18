//
//  MRLoginViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-9-18.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"

@interface MRLoginViewController : MSViewController

@property (nonatomic,strong) void (^loginblock)(BOOL login);

@end
