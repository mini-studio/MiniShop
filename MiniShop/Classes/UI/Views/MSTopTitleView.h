//
//  MSTopTitleView.h
//  MiniShop
//
//  Created by Wuquancheng on 13-11-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTopTitleView : UIView
@property (nonatomic,strong) void (^selected)(id userInfo);
@property (nonatomic)int selectedIndex;
- (void)addTitle:(NSString*)title userInfo:(id)userInfo;
- (id)userInfoAtIndex:(int)index;
- (void)setSelectedIndex:(int)selectedIndex cascade:(BOOL)cascade;
- (void)setSlidePercent:(CGFloat)percent left:(BOOL)left;
@end
