//
//  MSNotiTableCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNotiTableCell.h"
#import "UIColor+Mini.h"

@interface MSNotiTableCell()
@property (nonatomic,strong)UILabel *noteLabel;
@property (nonatomic,strong)UIImageView *onlineImageView;
@property (nonatomic,strong)UIImageView *msSeparatorView;
@end

@implementation MSNotiTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
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

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.onlineImageView.hidden = YES;
    self.imageView.image = nil;
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
    
    self.detailTextLabel.origin = CGPointMake(self.textLabel.left, self.textLabel.bottom+10);

    if ( [self.item isKindOfClass:[MSNotiItemGroupInfo class]] )
    {
        self.msSeparatorView.center = CGPointMake(self.width/2, self.textLabel.bottom+10);
        self.msSeparatorView.width = width;
        self.msSeparatorView.hidden = NO;
        if (![self.item read])
        {
            self.textLabel.width -= 40;
            self.onlineImageView.hidden = NO;
            self.onlineImageView.origin = CGPointMake(self.width - 45, 12);
        }
    }
    else {
        self.msSeparatorView.hidden = YES;
    }
}

- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath backgroundCorlor:(UIColor *)backgroundCorlor highlightedBackgroundCorlor:(UIColor *)highlightedBackgroundCorlor  sectionRowNumbers:(NSInteger)numberOfRow
{
    if ( [self.item.type isEqualToString:MSStoreNewsTypeOffical] || [self.item.type isEqualToString:MSStoreNewsTypeTopic] || [self.item.type isEqualToString:MSStoreNewsTypeURL] )
    {
        UIImage *image = [UIImage imageNamed:@"news_cell_bg"];
        [super setCellTheme:tableView indexPath:indexPath background:image highlightedBackground:image sectionRowNumbers:numberOfRow];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"news_online_cell_bg"];
        [super setCellTheme:tableView indexPath:indexPath background:image highlightedBackground:image sectionRowNumbers:numberOfRow];
    }
}

- (void)setItem:(MSNotiItemInfo *)item
{
    _item = item;
    self.textLabel.text = item.name;
    self.detailTextLabel.text = item.intro;
    if ( [item.type isEqualToString:MSStoreNewsTypeOffical] || [item.type isEqualToString:MSStoreNewsTypeTopic] || [item.type isEqualToString:MSStoreNewsTypeURL] )
    {
        self.textLabel.textColor = [UIColor colorWithRGBA: 0xcaab7fFF];
        self.detailTextLabel.textColor = self.textLabel.textColor;
        self.imageView.image = [UIImage imageNamed:@"news_message_icon"];;
    }
    else
    {
        self.textLabel.textColor =  [UIColor colorWithRGBA:0x9E2929FF];
        self.detailTextLabel.textColor = [UIColor colorWithRGBA:0x6C6C6CFF];
        self.noteLabel.text = [item typeNoteDesc];
        self.noteLabel.textColor = [item typeNoteColor];
        self.imageView.image = [UIImage imageNamed:@"news_online_icon"];
    }
    if ( item.publish_time == nil )
    {
        item.publish_time = @"";
    }
    self.textLabel.highlightedTextColor = self.textLabel.textColor;
}

- (void)sizeToFit
{
    [super sizeToFit];
    CGFloat height = 0;
    CGFloat width = self.width-40;
    self.textLabel.width = width;
    self.detailTextLabel.width = width-40;
    CGSize size = CGSizeMake(10,self.textLabel.font.lineHeight);
    height += (size.height);
    size = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font constrainedToSize:CGSizeMake(self.detailTextLabel.width , MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;    
    height += 36;
    self.height = height;
}

@end
