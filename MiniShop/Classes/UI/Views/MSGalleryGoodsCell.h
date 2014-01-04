//
//  MSGalleryGoodsCell.h
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSShopGalleryInfo;
@class MSGoodsItem;

@interface MSGalleryGoodsCell : UITableViewCell
@property (nonatomic,strong)MSShopGalleryInfo *galleyInfo;
@property (nonatomic,assign)MSViewController *controller;
@property (nonatomic,strong) void (^handleTouchItem)(MSGoodsItem* itemInfo);

+ (CGFloat)heightWithImageCount:(NSInteger)count;
@end
