//
//  MSPotentialCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIPotentialCell.h"
#import "MSGoodsList.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Mini.h"
#import "MSWebChatUtil.h"
#import "UIImage+Mini.h"
#import "WXApiObject.h"


@interface MSUIPotentialGoodsView : UIView
@property (nonatomic,strong) MiniUIButton *imageButton;
@property (nonatomic,strong) MiniUIButton *shareButton;
@property (nonatomic,strong) MSGoodsItem   *info;
@end

@implementation MSUIPotentialGoodsView

- (id)initWithFrame:(CGRect)frame userInfo:(MSGoodsItem*)info
{
    if (self = [super initWithFrame:frame])
    {
        _info = info;
        UIImage *btnBg = [UIImage imageNamed:@"image_bg"];
        self.imageButton = [MiniUIButton buttonWithBackGroundImage:btnBg highlightedBackGroundImage:btnBg title:@""];
        CGFloat border  = 10;
        self.imageButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        CGRect imageFrame = self.bounds;
        imageFrame = CGRectInset(imageFrame, border, border);
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [self.imageButton addSubview:imageView];
        __weak UIImageView *pImageView = imageView;
        __PSELF__;
        [imageView setImageWithURL:[NSURL URLWithString:info.image_url] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            pImageView.size =  [image sizeForScaleToFixSize:imageFrame.size];
            if ( pImageView.size.height > imageFrame.size.height )
            {
                
            }
            CGPoint btnCenter = pSelf.imageButton.center;
            pSelf.imageButton.size = CGSizeMake(pImageView.size.width+2*border, pImageView.size.height + 2*border);
            pSelf.imageButton.center = btnCenter;
            pImageView.origin = CGPointMake(border, border);
            pImageView.image = image;
            pSelf.info.image = image;
            
        } failure:^(NSError *error) {
            
        }];
        self.imageButton.showsTouchWhenHighlighted = YES;
        [self addSubview:self.imageButton];

    }
    return self;
}


@end

@interface MSUIPotentialCell()
@property (nonatomic,strong) NSMutableArray *goodsArray;
@property (nonatomic,strong) UIView         *galleryView;
@property (nonatomic) int numbersOfRow;
@end

@implementation MSUIPotentialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.numbersOfRow = 2;
        self.goodsArray = [NSMutableArray array];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.textColor = [UIColor colorWithRGBA:0x6c6c6cff];
        self.galleryView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.galleryView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.galleryView.frame = CGRectMake(0, 0, self.width, self.height);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.galleryView removeAllSubviews];
    [self.goodsArray removeAllObjects];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    CGFloat itemWidth = (WINDOW.frame.size.width - 16)/self.numbersOfRow;
    CGFloat gap = 4;
    CGFloat itemheight = itemWidth ;// + 40;
    [self.galleryView removeAllSubviews];
    for ( int index = 0; index < dataSource.count; index++ )
    {
        int col = index%self.numbersOfRow;
        int row = index/self.numbersOfRow;
        MSGoodsItem *item = [dataSource objectAtIndex:index];
        CGRect rect = CGRectMake( col*(itemWidth+gap) + gap,  (row*(itemheight+gap)), itemWidth, itemheight);
        MSUIPotentialGoodsView *v = [[MSUIPotentialGoodsView alloc] initWithFrame:rect userInfo:item];
        [self.goodsArray addObject:v];
        [self.galleryView addSubview:v];
        v.imageButton.userInfo = item;
        [v.imageButton setTouchupHandler:^(MiniUIButton *button) {
            [self actionForDetail:button.userInfo];
        }];
        v.shareButton.userInfo = item;
        [v.shareButton setTouchupHandler:^(MiniUIButton *button) {
            [self actionForShare:button.userInfo];
        }];
    }
}

- (UITableView*)tableView
{
    UIView *superv = self.superview;
    while ( superv !=nil && ![superv isKindOfClass:[UITableView class]])
    {
        superv = [superv superview];
    }
    if ( [superv isKindOfClass:[UITableView class]])
    {
        return (UITableView*)superv;
    }
    return nil;
}


- (void)actionForDetail:(MSGoodsItem *)item
{
    if ( self.handleTouchItem )
    {
        self.handleTouchItem(item);
    }
}

- (void)actionForShare:(MSGoodsItem *)item
{
    //item.shop_name = self.shopInfo.title;
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的店铺到" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareGoodsItem:item scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareGoodsItem:item scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}

+ (CGFloat)heightForShopInfo:(NSMutableArray*)array
{
    int numbersOfRow = 2;
    CGFloat itemWidth = (WINDOW.frame.size.width - 16)/numbersOfRow;
    CGFloat gap = 4;
    CGFloat itemheight = itemWidth ;// + 40;
    int rows = (array.count/numbersOfRow) +  (array.count%numbersOfRow==0?0:1);
    CGFloat height = rows*(itemheight+gap);
    return height;
}
@end
