//
//  MiniUIImageView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniUIPhotoImageView.h"
#import "UIImage+Mini.h"

@interface MiniUIPhotoImageView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *bgImageView;
@property (nonatomic,strong)MiniUIButton *button;
@end

@implementation MiniUIPhotoImageView

- (id)init
{
    self = [super init];
    if (self) {
         [self initSubViews];
    }
    return self;
 
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    UIImage *image = [UIImage imageNamed:@"image_bg"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.width/2, image.size.height/2,image.size.width/2, image.size.height/2)];
    self.bgImageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:self.bgImageView];
    self.imageView = [[UIImageView alloc] init];
    self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.button];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.bgImageView.frame = frame;
    self.button.frame = self.bounds;
}

- (void)setImage:(UIImage *)image
{
    CGSize size = self.size;
    size.width -= 16;
    size.height -= 16;
    CGSize nsize = [image sizeForScaleToFixSize:size];
    self.imageView.size = nsize;
    self.imageView.center = CGPointMake(self.width/2, self.height/2);
    self.imageView.image = image;
    [self addSubview:_imageView];
}

- (void)addTartget:(id)target selector:(SEL)selector userInfo:(id)userInfo
{
    self.button.userInfo = userInfo;
    [self.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
