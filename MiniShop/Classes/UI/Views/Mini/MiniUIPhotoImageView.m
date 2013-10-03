//
//  MiniUIImageView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniUIPhotoImageView.h"
#import "UIImage+Mini.h"
#import "UIColor+Mini.h"

@interface MiniUIPhotoImageView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *bgImageView;
@property (nonatomic,strong)MiniUIButton *button;
@property (nonatomic,strong)UILabel      *promptLabel;
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
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];
    
    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
    self.promptLabel.backgroundColor = [UIColor colorWithRGBA:0x33333355];
    self.promptLabel.layer.cornerRadius = 8;
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.font = [UIFont systemFontOfSize:12];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.layer.masksToBounds = YES;
    self.promptLabel.hidden = YES;
    [self addSubview:self.promptLabel];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.bgImageView.frame = frame;
    self.button.frame = self.bounds;
    [self.promptLabel sizeToFit];
    self.promptLabel.width = self.promptLabel.width + 10;
    self.promptLabel.center = CGPointMake(self.imageView.right - self.promptLabel.width/2-4, self.imageView.bottom- self.promptLabel.height/2-4);
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
}

- (void)setPrompt:(NSString *)prompt
{
    self.promptLabel.text = prompt;
    self.promptLabel.hidden = NO;
    
}

- (void)addTartget:(id)target selector:(SEL)selector userInfo:(id)userInfo
{
    self.button.userInfo = userInfo;
    [self.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
