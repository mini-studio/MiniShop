//
//  MSNShopInfoView.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-7.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopInfoView.h"
#import "UIImageView+WebCache.h"
@interface MSNShopInfoView()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *address;
@end

@implementation MSNShopInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.imageView];
    }
    return self;
}


- (void)setShopInfo:(MSNShopInfo *)shopInfo
{
    _shopInfo = shopInfo;
    if ( shopInfo.shop_logo.length >0 ) {
        __weak UIImageView *imageView = self.imageView;
        [imageView setImageWithURL:[NSURL URLWithString:shopInfo.shop_logo]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
            imageView.image = image;
        } failure:^(NSError *error) {
            
        }];

    }
}


@end
