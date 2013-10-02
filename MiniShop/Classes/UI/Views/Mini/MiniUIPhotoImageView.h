//
//  MiniUIImageView.h
//  MiniShop
//
//  Created by Wuquancheng on 13-9-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniUIPhotoImageView : UIView
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,strong) UIImage *image;

- (void)addTartget:(id)target selector:(SEL)selector userInfo:(id)userInfo;
@end
