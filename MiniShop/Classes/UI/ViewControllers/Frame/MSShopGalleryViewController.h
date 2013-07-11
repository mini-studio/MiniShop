//
//  MSShopGalleryViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-5-29.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
@class MSNotiItemInfo;

@interface MSShopGalleryViewController : MSViewController
@property (nonatomic,strong) MSNotiItemInfo *shopInfo;
@property (nonatomic) BOOL autoLayout;
@end
