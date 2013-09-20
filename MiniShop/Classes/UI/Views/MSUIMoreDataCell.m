//
//  MSUIMoreDataCell.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIMoreDataCell.h"
#import "UITableViewCell+GroupBackGround.h"

@interface MSUIMoreDataCell()
@end

@implementation MSUIMoreDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] )
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor] ;
        self.backgroundView = nil;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
