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
#import "MSNGoodsList.h"
#import "MSNDetailViewController.h"

@interface MSNGoodsTableCell()
@property (nonatomic,strong)NSMutableArray *imageArray;
@end

@implementation MSNGoodsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageArray = [NSMutableArray arrayWithCapacity:1];
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
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
    CGFloat width = self.width;
    __block CGFloat top =  self.textLabel.bottom;
    [self.imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *imageView = [self.imageArray objectAtIndex:idx];
        int mod = idx%3;
        if ( mod == 2 ) {
            CGFloat imageSize = self.width;
            imageView.origin = CGPointMake(0, top );
            top += imageSize;
        }
        else {
            CGFloat imageSize = self.width/2;
            if ( mod == 0 ) {
                if ( idx == self.imageArray.count-1 ) {
                    imageSize = width;
                }
                imageView.origin = CGPointMake(0, top );
                top += imageSize;
            }
            else {
                CGFloat secondTop = top - imageSize;
                imageView.origin = CGPointMake(imageSize, secondTop );
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
            CGFloat imageSize = self.width;
            imageView.size = CGSizeMake(imageSize, imageSize);
            isBig = YES;
        }
        else {
            CGFloat imageSize = self.width/2;
            if ( mod == 0 ) {
                if ( index == count-1 ) {
                    imageSize = self.width;
                    isBig = YES;
                }
                imageView.size =  CGSizeMake(imageSize, imageSize);
            }
            else {
                imageView.size = CGSizeMake(imageSize, imageSize);
                
            }
        }
        MSNGoodsItem *item = [_items objectAtIndex:index];
        [imageView addTartget:self selector:@selector(actionImageTap:) userInfo:item];
        [imageView.imageView setImageWithURL:[NSURL URLWithString:(isBig?item.big_image_url:item.small_image_url)]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
            imageView.prompt = [NSString stringWithFormat:@" ¥ %@ ",item.goods_sale_price];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)actionImageTap:(MiniUIButton*)button
{
    MSNGoodsItem *item = [button userInfo];
    MSNDetailViewController *controller = [[MSNDetailViewController alloc] init];
    if ( [self.controller respondsToSelector:@selector(allGoodsItems)] ) {
        NSArray *all = [self.controller valueForKey:@"allGoodsItems"];
        controller.items = all;
        NSUInteger index = [all indexOfObject:item];
        if (index != NSNotFound)
            controller.defaultIndex = index;
    }
    else {
        controller.items = @[item];
    }
    [self.controller.navigationController pushViewController:controller animated:YES];
}

- (void)clearMemory
{
    for ( MiniUIPhotoImageView *imageView in self.imageArray ) {
        imageView.image=nil;
    }
}

/**
 NSArray 元素的类型为 MSNGoodsItem
 */
+ (CGFloat)heightForItems:(NSArray*)items width:(CGFloat)maxWidth
{
    CGFloat height = 0;
    CGFloat width = maxWidth;
    CGSize size = CGSizeMake(0,0);
    height += (size.height);
    int count = items.count;
    if ( count>0 ) { // 3图片两行为一组
        CGFloat singleLineHeight = width;
        CGFloat multLineHeight = (singleLineHeight)/2;
        int row = count/3;
        int reset = count%3;
        size.height = row*(singleLineHeight + multLineHeight);
        if ( reset == 2 ) {
            size.height  += (multLineHeight);
        }
        else if ( reset == 1 ) {
            size.height  += (singleLineHeight);
        }
        height += size.height;
    }
    return height;
}

@end
