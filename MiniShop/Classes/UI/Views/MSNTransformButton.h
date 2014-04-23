//
//  MSNTransformButton.h
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSNTransformButton;

@protocol MSTransformButtonDelegate <NSObject>
@optional
- (void)transformButtonValueChanged:(MSNTransformButton*)button;
@end

@interface MSNTransformButton : UIView
@property (nonatomic,assign) id<MSTransformButtonDelegate> delegate;
@property (nonatomic,strong) NSArray *items;//string array
@property (nonatomic,strong) NSArray *values;//string array
@property (nonatomic) int selectedIndex;
@property (nonatomic) int fontSize;
@property (nonatomic,strong)UIColor *fontColor;

- (void)setAccessoryImage:(UIImage *)accessoryImage himage:(UIImage *)hImage;
- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated;
- (void)setSelectedIndex:(int)selectedIndex animated:(BOOL)animated withEvent:(BOOL)withEvent;
- (void)setItems:(NSArray *)items defaultIndex:(int)index;
- (id)selectedValue;
@end
