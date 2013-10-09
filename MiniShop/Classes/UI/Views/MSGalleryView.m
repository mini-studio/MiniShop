//
//  MSGalleryView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSGalleryView.h"
#import "UIImageView+WebCache.h"
#import "MiniUIPhotoImageView.h"
#import "UIColor+Mini.h"
#import "UIImage+Mini.h"

@interface MSGalleryView ()
@property (nonatomic,strong) UILabel   *titleLabel;
@property (nonatomic,strong) UIView    *headerView;
@property (nonatomic) CGFloat imageSize;
@property (nonatomic) CGFloat gap;
@end

@implementation MSGalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gap = 4;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setData:(NSArray *)info addr:(NSString *(^)(int index, bool isBig))addr price:(NSString*(^)(int index))price userInfo:(id (^)(int index))userinfo
{
    int count = info.count;
    CGFloat top = 10;
    for ( NSInteger index = 0; index < count; index++ )
    {
        bool big = NO;
        CGRect frame = CGRectZero;
        int mod = index%3;
        if ( mod == 2 ) {
            CGFloat imageSize = self.width - 20;
            frame = CGRectMake(10, top, imageSize, imageSize);
            top += ( imageSize + 4 );
            big = YES;
        }
        else {
            CGFloat imageSize = (self.width - 24)/2;
            if ( mod == 0 ) {
                if ( index == count-1 ) {
                    imageSize = self.width - 20;
                    big = YES;
                }
                frame =  CGRectMake(10, top,imageSize, imageSize);
                top += ( imageSize + 4 );
            }
            else {
                frame = CGRectMake(self.width-10-imageSize, top-4-imageSize,imageSize, imageSize);
            }
        }
        MiniUIPhotoImageView *imageView = [[MiniUIPhotoImageView alloc] initWithFrame:frame];
        [imageView addTartget:self selector:@selector(buttonTap:) userInfo:userinfo(index)];
        [self addSubview:imageView];
        __weak MiniUIPhotoImageView *pimageView = imageView;
        NSString *uri = addr(index,big);
        [imageView.imageView setImageWithURL:[NSURL URLWithString:uri] placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            pimageView.image = image;
            pimageView.prompt = [NSString stringWithFormat:@" ¥%@ ",price(index)];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)buttonTap:(MiniUIButton *)button
{
    if (self.handleTap)
    {
        self.handleTap(button.userInfo);
    }
}

- (void)clear
{
    self.title = nil;
    [self removeAllSubviews];
}

+ (CGFloat)heightWithImageCount:(NSInteger)count hasTitle:(BOOL)hasTitle
{
    CGFloat viewWidth = WINDOW.frame.size.width;
    CGFloat singleLineHeight = viewWidth-20;
    CGFloat multLineHeight = (singleLineHeight-4)/2;
    int row = count/3;
    int reset = count%3;
    CGFloat gap = 4;
    CGFloat height = row*(singleLineHeight + multLineHeight + 2*4);
    if ( reset == 2 ) {
        height  += (multLineHeight+gap);
    }
    else if ( reset == 1 ) {
        height  += (singleLineHeight+gap);
    }
    return height + 20;
}
@end
