//
//  MSNotiTableCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNotiTableCell.h"
#import "UIColor+Mini.h"
#import "UIDevice+Ext.h"
#import "UIImageView+WebCache.h"
#import "MiniUIPhotoImageView.h"
#import "UIImage+Mini.h"
#import "RTLabel.h"
#import "MSDetailViewController.h"
#import "MSShopGalleryViewController.h"

@interface MSNotiTableCell()
@property (nonatomic,strong)UILabel *noteLabel;
@property (nonatomic,strong)UIImageView *onlineImageView;
@property (nonatomic,strong)UIImageView *msSeparatorView;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,strong)RTLabel *rtlabel;
@property (nonatomic,strong)UIImageView *noneNewImageView;
@end

@implementation MSNotiTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.numberOfLines = 1;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithRGBA:0x9E2929FF];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor colorWithRGBA:0x555555FF];
      
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;     
        
        UIImage *image = [UIImage imageNamed:@"news_online_tag"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width/2, 0, image.size.width/2)];
        self.onlineImageView = [[UIImageView alloc] initWithImage:image];
        self.onlineImageView.size = CGSizeMake(44, 24);
        [self addSubview:self.onlineImageView];
        self.onlineImageView.hidden = YES;
        CGRect frame = self.onlineImageView.bounds;
        frame.origin.x = 6;
        frame.size.width -= 6;
        self.noteLabel = [[UILabel alloc] initWithFrame:frame];
        self.noteLabel.font = [UIFont systemFontOfSize:14];
        self.noteLabel.adjustsFontSizeToFitWidth = YES;
        self.noteLabel.backgroundColor = [UIColor clearColor];
        self.noteLabel.textAlignment = NSTextAlignmentCenter;
        [self.onlineImageView addSubview:self.noteLabel];
        self.msSeparatorView = [[UIImageView alloc] initWithImage:[MiniUIImage imageNamed:@"news_separator"]];
        [self addSubview:self.msSeparatorView];
        self.imageArray = [NSMutableArray array];
        self.rtlabel = [[RTLabel alloc] initWithFrame:CGRectMake(30,10,270,20)];
        [self addSubview:self.rtlabel];
        
        image = [UIImage imageNamed:@"news_online_cell_bg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
        self.noneNewImageView = [[UIImageView alloc] initWithImage:image];
        _noneNewImageView.frame = CGRectMake(10, 10, WINDOW.width-20, 80);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.noneNewImageView.width, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"今日无上新";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRGBA: 0xcaab7fFF];
        label.center = CGPointMake(_noneNewImageView.width/2, _noneNewImageView.height/2);
        [self.noneNewImageView addSubview:label];
        
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.onlineImageView.hidden = YES;
    self.imageView.image = nil;
    for ( UIImageView *imageView in self.imageArray ) {
        [imageView removeFromSuperview];
    }
    [self.imageArray removeAllObjects];
    [self.noneNewImageView removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.width-20;
    if ( self.imageView.image != nil )
    {
        self.textLabel.width = width-30;
        self.imageView.frame = CGRectMake(15, 13, 18, 18);
        self.textLabel.origin = CGPointMake(36, 12);
    }
    else
    {
        self.textLabel.origin = CGPointMake(10, 12);
    }
    
    if ( [self.item isKindOfClass:[MSNotiGroupInfo class]] )
    {
        self.msSeparatorView.center = CGPointMake(self.width/2, self.textLabel.bottom+10);
        self.msSeparatorView.width = width;
        self.msSeparatorView.hidden = NO;
        if (![self.item read])
        {
            self.textLabel.width -= 40;
            self.onlineImageView.hidden = NO;
            self.onlineImageView.origin = CGPointMake(self.width - 50, 12);
        }
    }
    else {
        self.msSeparatorView.hidden = YES;
    }
    
    self.detailTextLabel.origin = CGPointMake(self.textLabel.left, self.textLabel.bottom+14);
    
    __block CGFloat top =  self.textLabel.bottom + 2;
    [self.imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         UIView *imageView = [self.imageArray objectAtIndex:idx];
        int mod = idx%3;
       
        if ( mod == 2 ) {
            CGFloat imageSize = self.width - 30;
            imageView.origin = CGPointMake(15, top );
            top += imageSize;
            top += 4;
        }
        else {
            CGFloat imageSize = ( self.width  - 34)/2;
            if ( mod == 0 ) {
                if ( idx == self.imageArray.count-1 ) {
                    imageSize = width - 30;
                }
                imageView.origin = CGPointMake(15, top );
                top += imageSize;
                top += 4;
            }
            else {
                CGFloat secondTop = top - imageSize - 4;
                imageView.origin = CGPointMake(imageSize + 20, secondTop );
    
            }
        }
    }];
}

- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath backgroundCorlor:(UIColor *)backgroundCorlor highlightedBackgroundCorlor:(UIColor *)highlightedBackgroundCorlor  sectionRowNumbers:(NSInteger)numberOfRow
{
    if ( [self.item.type isEqualToString:MSStoreNewsTypeOffical] || [self.item.type isEqualToString:MSStoreNewsTypeTopic] || [self.item.type isEqualToString:MSStoreNewsTypeURL] )
    {
        UIImage *image = [UIImage imageNamed:@"news_online_cell_bg"];
        [super setCellTheme:tableView indexPath:indexPath background:image highlightedBackground:image sectionRowNumbers:numberOfRow];
    }
    else {
        UIImage *image = nil;
        if ( !self.item.isNews ) {
             image = [UIImage imageNamed:@"news_online_cell_bg"];
        }
        [super setCellTheme:tableView indexPath:indexPath background:image highlightedBackground:image sectionRowNumbers:numberOfRow];
    }
}

- (void)setItem:(MSNotiItemInfo *)item
{
    _item = item;
     self.textLabel.text = item.name;
    
    if ( [item.type isEqualToString:MSStoreNewsTypeOffical] || [item.type isEqualToString:MSStoreNewsTypeTopic] || [item.type isEqualToString:MSStoreNewsTypeURL] )
    {
        self.textLabel.textColor = [UIColor colorWithRGBA: 0xcaab7fFF];
        self.detailTextLabel.textColor = self.textLabel.textColor;
        self.imageView.image = [UIImage imageNamed:@"news_message_icon"];
        self.detailTextLabel.text = item.intro;
        self.rtlabel.hidden = YES;
    }
    else
    {
        self.textLabel.textColor =  [UIColor colorWithRGBA:0x9E2929FF];
        self.detailTextLabel.textColor = [UIColor colorWithRGBA:0x6C6C6CFF];
        //self.noteLabel.text = [item typeNoteDesc];
        self.noteLabel.textColor = [item typeNoteColor];
        self.msSeparatorView.hidden = YES;
        self.imageView.image = nil;
        if ( [item isKindOfClass:[MSPicNotiGroupInfo class]] ) {
            self.textLabel.text = @" ";
            self.detailTextLabel.text = nil;
            MSPicNotiGroupInfo *groupInfo = (MSPicNotiGroupInfo*)item;
            int count = groupInfo.items_info.goods_info.count;
            self.rtlabel.hidden = NO;
            if ( count == 0 ) {
                [self addSubview:self.noneNewImageView];
            }
            else {
                NSString *title = nil;
                if ( item.isNews && [groupInfo.items_info.shop_info.publish_time rangeOfString:@"天"].location==NSNotFound ) {
                    title = [NSString stringWithFormat:@"<font color='#333333'>今日上新 </font><font color='#7D7D7D'>%@</font><font color='#C95865'> +%dNEW</font>",groupInfo.items_info.shop_info.publish_time,count];
                }
                else {
                   title = [NSString stringWithFormat:@"<font color='#7D7D7D'>%@</font><font color='#C95865'>+%dNEW</font>",groupInfo.items_info.shop_info.publish_time,count];
                }
                [self.rtlabel setText:title];
                for (int index = 0; index < count; index++) {
                    MiniUIPhotoImageView *imageView = [[MiniUIPhotoImageView alloc] init];
                    [self.imageArray addObject:imageView];
                    [self addSubview:imageView];
                    int mod = index%3;
                    if ( mod == 2 ) {
                        CGFloat imageSize = self.width - 30;
                        imageView.size = CGSizeMake(imageSize, imageSize);
                    }
                    else {
                        CGFloat imageSize = (self.width - 34)/2;
                        if ( mod == 0 ) {
                            if ( index == count-1 ) {
                                imageSize = self.width - 30;
                            }
                            imageView.size =  CGSizeMake(imageSize, imageSize);
                        }
                        else {
                            imageView.size = CGSizeMake(imageSize, imageSize);
                            
                        }
                    }
                    MSGoodItem *i = [groupInfo.items_info.goods_info objectAtIndex:index];
                    [imageView addTartget:self selector:@selector(actionImageTap:) userInfo:i];
                    
                    if ( i.mid == MSDataType_MoreData ) {
                        imageView.image = [UIImage imageNamed:@"more_new"];
                    }
                    else {
                        [imageView.imageView setImageWithURL:[NSURL URLWithString:i.small_image_url]  placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
                            imageView.image = image;
                            imageView.prompt = [NSString stringWithFormat:@"价格: %@",i.price];
                        } failure:^(NSError *error) {
                            
                        }];
                    }
                }
            }
        }
        else {
            self.msSeparatorView.hidden = NO;
            self.detailTextLabel.text = item.intro;
            self.textLabel.textColor =  [UIColor colorWithRGBA:0x9E2929FF];
            self.detailTextLabel.textColor = [UIColor colorWithRGBA:0x6C6C6CFF];
            self.noteLabel.text = [item typeNoteDesc];
            self.noteLabel.textColor = [item typeNoteColor];
            self.imageView.image = [UIImage imageNamed:@"news_online_icon"];
        }
    }
    if ( item.publish_time == nil )
    {
        item.publish_time = @"";
    }
    self.textLabel.highlightedTextColor = self.textLabel.textColor;
}

- (void)actionImageTap:(MiniUIButton*)sender
{
    MSGoodItem *item = sender.userInfo;
    if ( item.mid == MSDataType_MoreData ) {
        MSShopGalleryViewController *c = [[MSShopGalleryViewController alloc] init];
        c.shopInfo = self.item;
        c.autoLayout = NO;
        [self.controller.navigationController pushViewController:c animated:YES];
    }
    else {
        MSPicNotiGroupInfo *groupInfo = (MSPicNotiGroupInfo*)self.item;
        NSInteger index = [groupInfo.items_info.goods_info indexOfObject:item];
        MSDetailViewController *c = [[MSDetailViewController alloc] init];
        c.itemInfo = self.item;
        MSGoodsList *lst = [[MSGoodsList alloc] init];
        lst.shop_id = groupInfo.items_info.shop_info.mid.integerValue;
        lst.shop_name = groupInfo.items_info.shop_info.shop_title;
        NSMutableArray *goods = [NSMutableArray arrayWithArray:groupInfo.items_info.goods_info];
        item =  goods.lastObject;
        if ( item.mid == MSDataType_MoreData ) {
            [goods removeObject:item];
        }
        lst.body_info = goods;
        c.goods = lst;
        c.defaultIndex = index;
        [self.controller.navigationController pushViewController:c  animated:YES];
    }
}


+ (CGFloat)heightForItem:(MSNotiItemInfo *)item width:(CGFloat)maxWidth
{
    CGFloat height = 0;
    CGFloat width = maxWidth-20;
    CGSize size = CGSizeMake(10,18);
    height += (size.height);
    if ( [item isKindOfClass:[MSPicNotiGroupInfo class]] ) {
        height += 10;
        MSPicNotiGroupInfo *groupInfo = (MSPicNotiGroupInfo*)item;
        int count = groupInfo.items_info.goods_info.count;
        if ( count > 0 ) {
            CGFloat singleLineHeight = width-10;
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
            height += 24;
        }
        else {
            return 100;
        }
    }
    else {
        UIFont *font = [UIFont systemFontOfSize:14];
        size = [item.intro sizeWithFont:font constrainedToSize:CGSizeMake(width - 40 , MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
         height += 44;
    }
   
    return height;
}

@end
