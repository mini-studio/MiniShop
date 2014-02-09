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
@property (nonatomic,strong)MiniUIButton *colorButton;
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
    self.promptLabel.backgroundColor = [UIColor colorWithRGBA:0x000000AA];
    //self.promptLabel.layer.cornerRadius = 2;
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.font = [UIFont systemFontOfSize:12];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.layer.masksToBounds = YES;
    self.promptLabel.hidden = YES;
    [self addSubview:self.promptLabel];
    self.colorButton = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"news_online_tag"] highlightedBackGroundImage:nil title:@""];
    [self.colorButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    self.colorButton.size = CGSizeMake(40, 20);
    self.colorButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.colorButton.hidden = YES;
    [self addSubview:self.colorButton];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.bgImageView.frame = frame;
    self.button.frame = self.bounds;
    if ( !self.promptLabel.hidden ) {
        [self.promptLabel sizeToFit];
        self.promptLabel.width = self.promptLabel.width + 10;
        self.promptLabel.center = CGPointMake(self.imageView.left+self.promptLabel.width/2, self.imageView.bottom- self.promptLabel.height/2);
    }
    if ( !self.colorButton.hidden ) {
        self.colorButton.center = CGPointMake(self.width-self.colorButton.width/2-1, self.height-self.colorButton.height/2-8);
    }
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

- (void)setColorPrompt:(NSString *)colorPrompt
{
    [self.colorButton setTitle:colorPrompt forState:UIControlStateNormal];
    [self.colorButton sizeToFit];
    self.colorButton.height = 20;
    self.colorButton.width += 10;
    self.colorButton.hidden = NO;
}

- (void)addTartget:(id)target selector:(SEL)selector userInfo:(id)userInfo
{
    self.button.userInfo = userInfo;
    [self.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
