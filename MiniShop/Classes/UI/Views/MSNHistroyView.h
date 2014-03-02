//
//  MSNHistroyView.h
//  MiniShop
//
//  Created by Wuquancheng on 14-3-2.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNHistroyView : UIView
@property(nonatomic,strong)NSArray *historyItems;
@property(nonatomic,strong)NSArray *hotItems;
@property(nonatomic,strong) void (^onSelected)(NSString *title);
- (void)reload;
@end
