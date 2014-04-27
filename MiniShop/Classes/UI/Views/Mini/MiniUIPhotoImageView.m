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

@interface MiniUIPhotoImagePromptView()
@property (nonatomic,strong)UIImageView *arrowImageView;
@end

@implementation MiniUIPhotoImagePromptView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.left = [self createLable:CGRectMake(0, 0, 40, self.height)];
        self.right = [self createLable:CGRectMake(0, 0, 40, self.height)];
        [self addSubview:self.left];
        [self addSubview:self.right];
        self.backgroundColor = [UIColor colorWithRGBA:0x000000AA];
        self.userInteractionEnabled = NO;
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon"]];
        self.arrowImageView.size = CGSizeMake(6, 10);
        self.arrowImageView.centerY = self.height/2;
        [self addSubview:self.arrowImageView];
    }
    return self;
}

- (UILabel*)createLable:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.masksToBounds = YES;
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.left.left = 5;
    if (self.right.text.length>0) {
        self.arrowImageView.hidden = NO;
        self.arrowImageView.left = self.left.right+5;
        self.right.left = self.arrowImageView.right+5;
    }
    else {
        self.arrowImageView.hidden = YES;
    }
}

- (void)sizeToFit
{
    [super sizeToFit];
    self.left.width = 100;
    [self.left sizeToFit];
    if (self.right.text.length>0) {
        self.right.width = 100;
        [self.right sizeToFit];
        self.width = 20 + self.left.width + self.right.width + self.arrowImageView.width;
    }
    else {
        self.right.width = 0;
        self.width = 10 + self.left.width;
    }
   
    [self setNeedsLayout];
}

@end

@interface MiniUIPhotoImageView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIView *imageContentView;
@property (nonatomic,strong)UIImageView *bgImageView;
@property (nonatomic,strong)MiniUIButton *button;
@property (nonatomic,strong)MiniUIButton *colorButton;
@property (nonatomic)CGFloat borderSize;
@end

@implementation MiniUIPhotoImageView

- (id)init
{
    self = [super init];
    if (self) {
        self.borderSize = 2;
        [self initSubViews];
        
    }
    return self;
 
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderSize = 2;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.backgroundColor = [UIColor whiteColor];
    CGRect frame = CGRectMake(self.borderSize, self.borderSize, self.width-2*self.borderSize, self.height-2*self.borderSize);
    self.imageContentView = [[UIView alloc] initWithFrame:frame];
    self.imageContentView.layer.masksToBounds = YES;
    [self addSubview:self.imageContentView];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.imageContentView addSubview:_imageView];
    self.layer.masksToBounds=YES;
    
    self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];

    self.prompView = [[MiniUIPhotoImagePromptView alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
    self.prompView.hidden = YES;
    [self addSubview:self.prompView];
    self.colorButton = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"news_online_tag"] highlightedBackGroundImage:nil title:@""];
    [self.colorButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    self.colorButton.size = CGSizeMake(40, 20);
    self.colorButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.colorButton.hidden = YES;
    [self addSubview:self.colorButton];

}

- (void)setSize:(CGSize)size
{
    [super setSize:size];
    CGRect frame = CGRectMake(self.borderSize, self.borderSize, self.width-2*self.borderSize, self.height-2*self.borderSize);
    self.imageContentView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.bgImageView.frame = frame;
    self.button.frame = self.bounds;
    self.prompView.origin = CGPointMake(self.borderSize, self.height-self.prompView.height-self.borderSize);
}

- (void)setImage:(UIImage *)image
{
    if (image==nil) {
        self.imageView.image = nil;
    }
    else {
        CGSize size = CGSizeMake(self.width+8, self.height+8);
        CGSize imageSize = image.size;
        CGFloat scal = size.width/imageSize.width;
        CGSize nsize = CGSizeMake(imageSize.width*scal, imageSize.height*scal);
        if (nsize.height<size.height) {
            scal = size.height/nsize.height;
            nsize.width = nsize.width*scal;
            nsize.height = nsize.height*scal;
        }
        self.imageView.size = nsize;
        self.imageView.image = image;
        self.imageView.center = CGPointMake(self.imageView.superview.width/2, self.imageView.superview.height/2);
        UIView *v = self.imageView.superview;
        v = self.imageView.superview;
        
    }
}

- (void)setLeftPrompt:(NSString*)left rightPrompt:(NSString*)right
{
    self.prompView.left.text = left;
    self.prompView.right.text = right;
    self.prompView.hidden = NO;
    [self.prompView sizeToFit];
}

- (void)prepareForReuse
{
    self.prompView.hidden = YES;
}

- (void)setColorPrompt:(NSString *)colorPrompt
{
    [self.colorButton setTitle:colorPrompt forState:UIControlStateNormal];
    [self.colorButton sizeToFit];
    self.colorButton.height = 20;
    self.colorButton.width += 10;
    self.colorButton.hidden = NO;
}

- (void)addTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo
{
    self.button.userInfo = userInfo;
    [self.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
