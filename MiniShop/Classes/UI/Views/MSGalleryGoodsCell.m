//
//  MSGalleryGoodsCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSGalleryGoodsCell.h"
#import "MSGalleryView.h"
#import "MSGoodsList.h"
#import "MSDetailViewController.h"

@interface MSGalleryGoodsCell ()
@property (nonatomic,strong) MSGalleryView *galleryView;
@end

@implementation MSGalleryGoodsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.galleryView = [[MSGalleryView alloc] initWithFrame:self.bounds];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        [self addSubview:self.galleryView];
        __PSELF__;
        [self.galleryView setHandleTap:^(id info) {
            [pSelf handleTap:info];
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.galleryView.frame = self.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.galleryView clear];
}

- (void)setGalleyInfo:(MSShopGalleryInfo *)galleyInfo
{
    _galleyInfo = galleyInfo;
    //self.galleryView.title = [NSString stringWithFormat:@"%@ 上新",galleyInfo.item_info.publish_time];
    [self.galleryView setData:galleyInfo.goods_info addr:^NSString *(int index, bool isBig) {
        MSGoodItem *good = [galleyInfo.goods_info objectAtIndex:index];
        return isBig?good.big_image_url:good.small_image_url;
    } price:^NSString*(int index) {
        MSGoodItem *good = [galleyInfo.goods_info objectAtIndex:index];
        return good.price;
    } userInfo:^id(int index) {
        MSGoodItem *good = [galleyInfo.goods_info objectAtIndex:index];
        return good;
    }];
}

- (void)handleTap:(MSGoodItem *)good
{
    if ( self.handleTouchItem )
    {
        self.handleTouchItem(good);
    }
}

+ (CGFloat)heightWithImageCount:(NSInteger)count
{
    return [MSGalleryView heightWithImageCount:count hasTitle:NO];
}
@end
