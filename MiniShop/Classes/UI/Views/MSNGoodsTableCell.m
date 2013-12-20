//
//  MSNGoodsTableCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-18.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNGoodsTableCell.h"
#import "UIColor+Mini.h"
#import "UIDevice+Ext.h"
#import "UIImageView+WebCache.h"
#import "MiniUIPhotoImageView.h"
#import "UIImage+Mini.h"
#import "RTLabel.h"
#import "MSDetailViewController.h"
#import "MSShopGalleryViewController.h"
#import "MSNFavshopList.h"

@interface MSNGoodsTableCell()
@property (nonatomic,strong)NSMutableArray *imageArray;
@end

@implementation MSNGoodsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    for ( UIImageView *imageView in self.imageArray ) {
        [imageView removeFromSuperview];
    }
    [self.imageArray removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.width-20;
    __block CGFloat top =  self.textLabel.bottom + 2;
    [self.imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *imageView = [self.imageArray objectAtIndex:idx];
        int mod = idx%3;
        if ( mod == 2 ) {
            CGFloat imageSize = self.width - 20;
            imageView.origin = CGPointMake(10, top );
            top += imageSize;
            top += 4;
        }
        else {
            CGFloat imageSize = ( self.width  - 24)/2;
            if ( mod == 0 ) {
                if ( idx == self.imageArray.count-1 ) {
                    imageSize = width - 20;
                }
                imageView.origin = CGPointMake(10, top );
                top += imageSize;
                top += 4;
            }
            else {
                CGFloat secondTop = top - imageSize - 4;
                imageView.origin = CGPointMake(imageSize + 14, secondTop );        
            }
        }
    }];
}


- (void)setItems:(NSArray *)items
{
    _items = items;
    self.imageView.image = nil;
    int count = items.count;
    BOOL isBig = NO;
    for (int index = 0; index < count; index++) {
        isBig = NO;
        MiniUIPhotoImageView *imageView = [[MiniUIPhotoImageView alloc] init];
        [self.imageArray addObject:imageView];
        [self addSubview:imageView];
        int mod = index%3;
        if ( mod == 2 ) {
            CGFloat imageSize = self.width - 20;
            imageView.size = CGSizeMake(imageSize, imageSize);
            isBig = YES;
        }
        else {
            CGFloat imageSize = (self.width - 24)/2;
            if ( mod == 0 ) {
                if ( index == count-1 ) {
                    imageSize = self.width - 20;
                    isBig = YES;
                }
                imageView.size =  CGSizeMake(imageSize, imageSize);
            }
            else {
                imageView.size = CGSizeMake(imageSize, imageSize);
                
            }
        }
        MSNGoodItem *item = [_items objectAtIndex:index];
        [imageView addTartget:self selector:@selector(actionImageTap:) userInfo:item];
        [imageView.imageView setImageWithURL:[NSURL URLWithString:(isBig?item.big_image_url:item.small_image_url)]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
            imageView.prompt = [NSString stringWithFormat:@" ¥%@ ",item.goods_sale_price];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)actionImageTap:(MSNGoodItem*)item
{
    
}


/**
 NSArray 元素的类型为 MSNGoodItem
 */
+ (CGFloat)heightForItems:(NSArray*)items width:(CGFloat)maxWidth
{
    CGFloat height = 0;
    CGFloat width = maxWidth-20;
    CGSize size = CGSizeMake(10,18);
    height += (size.height);
    int count = items.count;
    if ( count>0 ) { // 3图片两行为一组
        CGFloat singleLineHeight = width;
        CGFloat multLineHeight = (singleLineHeight-4)/2;
        int row = count/3;
        int reset = count%3;
        size.height = row*(singleLineHeight + multLineHeight + 8);
        if ( reset == 2 ) {
            size.height  += (multLineHeight+4);
        }
        else if ( reset == 1 ) {
            size.height  += (singleLineHeight+4);
        }
        height += size.height;
        height += 14;
    }
    return height;
}

@end
