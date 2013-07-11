//
//  MSGalleryView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSGalleryView.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Mini.h"
#import "UIImage+Mini.h"

@interface MSGalleryView ()
@property (nonatomic,strong) UILabel   *titleLabel;
@property (nonatomic,strong) UIView    *headerView;
@property (nonatomic) CGFloat imageSize;
@property (nonatomic) CGFloat gap;
@property (nonatomic) int numbersOfRow;
@end

@implementation MSGalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numbersOfRow = 2;
        self.imageSize = (WINDOW.frame.size.width - 16)/self.numbersOfRow;
        self.gap = 4;
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 24)];
        [self addSubview:header];
        header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"time_bg"]];
        CGRect fr = header.bounds;
        fr.origin.x = 24;
        self.titleLabel = [[UILabel alloc] initWithFrame:fr];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor =  [UIColor colorWithRGBA:0x6c6c6cff];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [header addSubview:self.titleLabel];
        self.headerView =  header;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_icon"]];
        imageView.frame = CGRectMake(6, 4, 14, 14);
        [header addSubview:imageView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( self.title.length > 0 )
    {
        [self addSubview:self.headerView];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setData:(NSArray *)info addr:(NSString *(^)(int index))addr userInfo:(id (^)(int index))userinfo
{
    UIImage *btnBg = [UIImage imageNamed:@"image_bg"];
    CGFloat offsetY = self.title.length > 0 ? 24 : 0;
    for ( NSInteger index = 0; index < info.count; index++ )
    {
        int row = index/self.numbersOfRow;
        int col = index%self.numbersOfRow ;
        MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:btnBg highlightedBackGroundImage:btnBg title:@""];
        button.frame = CGRectMake(col*(self.imageSize+self.gap)+self.gap, offsetY + row*(self.imageSize+self.gap)+self.gap, self.imageSize, self.imageSize);
        
        CGFloat border = 8;
        CGRect iframe = CGRectInset( button.bounds, border, border) ;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:iframe];
        [button addSubview:imageView];
        button.userInfo = userinfo(index);
        [self addSubview:button];
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        button.showsTouchWhenHighlighted = YES;
        
        __weak UIImageView *pimageView = imageView;
        [imageView setImageWithURL:[NSURL URLWithString:addr(index)] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            if ( image != nil && image.size.width > 0 && image.size.height > 0 )
            {
                CGSize imageSize = [image sizeForScaleToFixSize:pimageView.size];
                CGPoint btnCenter = button.center;
                CGSize size = CGSizeMake(imageSize.width+2*border, imageSize.height+2*border);
                button.frame = CGRectMake(btnCenter.x-size.width/2, btnCenter.y-size.height/2, size.width, size.height);
                pimageView.size = imageSize;
                pimageView.image = image;
                pimageView.center = CGPointMake(size.width/2, size.height/2);
            }
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
    int numbersOfRow = 2;
    CGFloat viewWidth = WINDOW.frame.size.width;
    CGFloat itemWidth = (viewWidth - 16)/numbersOfRow;
    CGFloat gap = 4;
    CGFloat itemheight = itemWidth ;// + 40;
    int rows = (count/numbersOfRow) +  (count%numbersOfRow==0?0:1);
    CGFloat height = rows*(itemheight+gap) + gap;
    if ( hasTitle )
    {
        height += 34;
    }
    return height;
}
@end
