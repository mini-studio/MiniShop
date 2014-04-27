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
#import "MiniUIWebViewController.h"
#import "MSUIWebViewController.h"

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
    __block CGFloat top =  self.textLabel.bottom;
    __block CGFloat left = 0;
    __block CGFloat half = self.width/4;
    [self.imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *imageView = [self.imageArray objectAtIndex:idx];
        imageView.origin = CGPointMake(left, top);
        left+=imageView.width;
        if (left+half>self.width) {
            left = 0;
            top = imageView.bottom;
        }
    }];
}

+ (CGSize)imageSizeForItem:(MSNGoodsItem*)item atIndex:(NSInteger)index total:(int)total maxWidth:(CGFloat)width
{
    CGSize size;
    if (item.imageSizeType==1) {
        size = CGSizeMake(width/2, width/2);
    }
    else if (item.imageSizeType==2) {
        size = CGSizeMake(width, width);
    }
    else {
        int mod = index%3;
        CGFloat imageSize = width;
        if ( mod == 2 ) {
            item.imageSizeType = 2;
        }
        else {
            if ((mod==0) && (index==total-1)) {
                item.imageSizeType = 2;
            }
            else {
                item.imageSizeType = 1;
                imageSize = width/2;
            }
        }
        size = CGSizeMake(imageSize, imageSize);
    }
    item.imageSize = size;
    return size;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    self.imageView.image = nil;
    int count = self.items.count;
    for (int index = 0; index < count; index++) {
        MSNGoodsItem *item = [self.items objectAtIndex:index];
        CGSize imageSize = [MSNGoodsTableCell imageSizeForItem:item atIndex:index total:count maxWidth:self.width];
        MiniUIPhotoImageView *imageView = [[MiniUIPhotoImageView alloc] init];
        imageView.size = imageSize;
        [self.imageArray addObject:imageView];
        [self addSubview:imageView];
        
        [imageView addTarget:self selector:@selector(actionImageTap:) userInfo:item];
        BOOL isBig = (item.imageSizeType==2);
        [imageView.imageView setImageWithURL:[NSURL URLWithString:(isBig?item.middle_image_url:item.small_image_url)]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
            [imageView setLeftPrompt:[NSString stringWithFormat:@"¥ %@",item.goods_sale_price] rightPrompt:[item economizer]];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)actionImageTap:(MiniUIButton*)button
{
    MSNGoodsItem *item = [button userInfo];
    if (item.goods_url.length==0) {
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
    else {
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] init];
        controller.uri = item.goods_url;
        [self.controller.navigationController pushViewController:controller animated:YES];
    }

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
    CGFloat tempWidth = 0;
    CGFloat halfWidht = maxWidth/4;
    NSMutableArray *newItems = [NSMutableArray array];
    for (MSNGoodsItem *item in items) {
        if (item.imageSizeType==0) {
            [newItems addObject:item];
        }
    }
    int count = newItems.count;
    for(int index=0;index<count;index++) {
        MSNGoodsItem *item = newItems[index];
        [self imageSizeForItem:item atIndex:index total:count maxWidth:width];
    }
    count = items.count;
    if ( count>0 ) { // 3图片两行为一组
        for (int index=0;index<items.count;index++) {
            MSNGoodsItem *item = items[index];
            [self imageSizeForItem:item atIndex:index total:count maxWidth:width];
            tempWidth += item.imageSize.width;
            if (tempWidth+halfWidht>maxWidth || index==count-1) {
                tempWidth = 0;
                height += item.imageSize.height;
            }
        }
    }
    return height;
}
@end


@implementation MSNGoodsHeaderTableCell
@end