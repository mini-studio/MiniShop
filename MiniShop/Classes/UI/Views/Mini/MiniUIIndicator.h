//
//  Indicator.h
//  Spiner
//
//  Created by Wuquancheng on 13-6-17.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface Indicator : UIView
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic) BOOL mAnimating;
@property (nonatomic,strong)UILabel     *label;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)setHidesWhenStopped:(bool)hidesWhenStopped;
@end

@interface MiniUIActivityIndicatorView : UIView

@property (nonatomic,strong) NSString * labelText;

- (void)showInView:(UIView *)view;

- (void)showInView:(UIView *)view userInterfaceEnable:(BOOL)enable;

- (void)hide;

- (BOOL)showing;

@end