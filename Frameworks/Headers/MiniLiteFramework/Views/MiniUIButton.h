//
//  MiniUIButton.h
//  LS
//
//  Created by wu quancheng on 12-6-11.
//  Copyright (c) 2012年 YouLu. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    UIControlEventTouchInsideRepeat = 1 <<  9 ,
    UIControlEventTouchUpInsideRepeat = 1 << 25
};

@interface MiniUIButton : UIButton
{
    id _userInfo;
	NSTimeInterval _longPressTimeInterval;
}
@property (nonatomic,retain) id userInfo;
@property (nonatomic, assign) NSTimeInterval longPressTimeInterval;

+ (MiniUIButton *)buttonWithBackGroundImage:(UIImage *)backGroundImage highlightedBackGroundImage:(UIImage *)highlightedBackGroundImage title:(NSString *)title;

+ (MiniUIButton *)buttonWithBackGroundImage:(UIImage *)backGroundImage highlightedBackGroundImage:(UIImage *)highlightedBackGroundImage resizableImageWithCapInsets:(UIEdgeInsets)insets title:(NSString *)title;

+ (MiniUIButton *)naviBackbuttonWithBackGroundImage:(UIImage *)backGroundImage highlightedBackGroundImage:(UIImage *)highlightedBackGroundImage title:(NSString *)title;

+ (MiniUIButton *)buttonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

- (void)setTouchupHandler:(void (^)(MiniUIButton *button))handler;


@end
