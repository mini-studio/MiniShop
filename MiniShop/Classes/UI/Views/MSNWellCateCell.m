//
//  MSNWellCateCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNWellCateCell.h"
#import "UIDevice+Ext.h"
#import "UIImageView+WebCache.h"
#import "MiniUIPhotoImageView.h"
@interface MSNWellCateCell()
@end

@implementation MSNWellCateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.contentView removeAllSubviews];
}

- (void)setGroup:(MSNWellCateGroup *)group
{
    _group = group;
    CGFloat buttonSize = ([[UIScreen mainScreen] bounds].size.width - 40)/3;
    int count = group.item.count;
    for ( int index = 0; index < count; index++ ) {
        MSNWellCate *cate = group.item[index];
        int row = index/3;
        int pos = index%3;
        int x = 10 + (pos*(buttonSize+10));
        int y = 10 + (row*(buttonSize+10));
        MiniUIPhotoImageView *imageView = [[MiniUIPhotoImageView alloc] init];
        imageView.frame = CGRectMake(x, y, buttonSize, buttonSize);
        [self.contentView addSubview:imageView];
        if ([cate.image_url rangeOfString:@"http"].location == 0 ) {
            [imageView.imageView setImageWithURL:[NSURL URLWithString:cate.image_url]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
                imageView.image = image;
            } failure:^(NSError *error) {
                
            }];
        }
        else {
            imageView.image = [UIImage imageNamed:cate.image_url];
        }
        [imageView addTarget:self selector:@selector(handleTouchImage:) userInfo:cate];
    }
}

- (void)handleTouchImage:(MiniUIButton*)button
{
    if (self.wellCateCellDelegate != nil ) {
        [self.wellCateCellDelegate handleTouchInfo:button.userInfo];
    }
}


+ (CGFloat)heightForGroup:(MSNWellCateGroup*)group
{
    int itemCount = group.item.count;
    int rownum = (itemCount/3) + ((itemCount%3)==0?0:1);
    CGFloat rowHeight = ([[UIScreen mainScreen] bounds].size.width - 40)/3 + 10;
    return rownum * rowHeight + 10;
}

@end
