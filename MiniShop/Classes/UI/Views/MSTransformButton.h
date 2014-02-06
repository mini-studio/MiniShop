//
//  MSTransformButton.h
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTransformButton;

@protocol MSTransformButtonDelegate <NSObject>
@optional
- (void)transformButtonValueChanged:(MSTransformButton*)button;
@end

@interface MSTransformButton : UIView
@property (nonatomic,assign) id<MSTransformButtonDelegate> delegate;
@property (nonatomic,strong) MiniUIButton *button;
@property (nonatomic,strong) NSArray *items;//string array
@property (nonatomic,strong) NSArray *values;//string array
@property (nonatomic) int selectedIndex;
@property (nonatomic) int fontSize;
@property (nonatomic,strong)UIColor *fontColor;

- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated;
- (void)setItems:(NSArray *)items defaultIndex:(int)index;
- (id)selectedValue;
@end
