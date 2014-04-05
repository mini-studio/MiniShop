//
//  MiniUIImageView.h
//  MiniShop
//
//  Created by Wuquancheng on 13-9-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniUIPhotoImagePromptView : UIView
@property (nonatomic,strong)UILabel *left;
@property (nonatomic,strong)UILabel *right;
@end

@interface MiniUIPhotoImageView : UIView
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,strong)MiniUIPhotoImagePromptView *prompView;

- (void)addTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;
- (void)setImage:(UIImage *)image;
- (void)setLeftPrompt:(NSString*)left rightPrompt:(NSString*)right;
- (void)prepareForReuse;
@end
