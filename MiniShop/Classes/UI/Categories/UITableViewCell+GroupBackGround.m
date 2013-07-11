//
//  UITableViewCell+GroupBackGround.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "UITableViewCell+GroupBackGround.h"

@interface MiniUITableGroupCellBackgroudView()
@property (nonatomic,strong)UIColor *innerBackgroundColor;
@property (nonatomic)NSInteger roundSize;
@end

@implementation MiniUITableGroupCellBackgroudView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super setBackgroundColor:[UIColor clearColor]];
        self.roundSize = 4;
    }
    return self;
}

- (void)setLoc:(TableViewCellLocation)loc
{
    _loc = loc;
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.innerBackgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    NSInteger lineWidth = 2.0f;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [self.innerBackgroundColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [self.borderColor CGColor]);
    
    if ( _loc == EFirstCell )
    {
        CGContextFillRect(c, CGRectMake(0.0f, rect.size.height - self.roundSize, rect.size.width, self.roundSize));
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, 0.0f, rect.size.height - self.roundSize);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height - self.roundSize);
        CGContextSetLineWidth(c, lineWidth);
        CGContextStrokePath(c);
        CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height - self.roundSize));
    }
    else if ( _loc  == ELastCell)
    {
        CGContextFillRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, self.roundSize));
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, lineWidth);
        CGContextMoveToPoint(c, 0.0f, self.roundSize);
        CGContextAddLineToPoint(c, 0.0f, 0.0f);
        CGContextStrokePath(c);
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, rect.size.width, 0.0f);
        CGContextAddLineToPoint(c, rect.size.width, self.roundSize);
        CGContextStrokePath(c);
        
        CGContextClipToRect(c, CGRectMake(0.0f, self.roundSize, rect.size.width, rect.size.height));
    }
    else if ( _loc == EMiddleCell )
    {
        CGContextFillRect(c, rect);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, lineWidth);
        CGContextMoveToPoint(c, 0.0f, 0.0f);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, 0.0f);
        CGContextStrokePath(c);
        return;
    }
    else
    {
        ;
    }
    // At this point the clip rect is set to only draw the appropriate
    // corners, so we fill and stroke a rounded rect taking the entire rect
    
    CGContextSetFillColorWithColor(c, [self.borderColor CGColor]);
    CGContextBeginPath(c);
    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
    CGContextFillPath(c);
    
    rect.origin.y+=1;
    rect.origin.x+=1;
    rect.size.height-=2;
    rect.size.width-=2;
    CGContextSetFillColorWithColor(c, [self.innerBackgroundColor CGColor]);
    CGContextBeginPath(c);
    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
    CGContextFillPath(c);
    
    //    CGContextBeginPath(c);
    //    CGContextSetLineWidth(c, lineWidth);
    //    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
    //    CGContextStrokePath(c);
    
    
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth,float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);// 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect),CGRectGetMinY(rect));// 3
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context);// 12
    CGContextRestoreGState(context);// 13
}

@end

@implementation UITableViewCell (GroupBackGround)
- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath backgroundCorlor:(UIColor *)backgroundCorlor highlightedBackgroundCorlor:(UIColor *)highlightedBackgroundCorlor  sectionRowNumbers:(NSInteger)numberOfRow
{
    TableViewCellLocation loc = (numberOfRow==1)?ESingleCell:
    (indexPath.row==0)?EFirstCell:(indexPath.row == (numberOfRow-1))?ELastCell:EMiddleCell;
    
    MiniUITableGroupCellBackgroudView *view = nil;
    self.backgroundColor = backgroundCorlor;
    if ( self.backgroundView == nil || ![self.backgroundView isKindOfClass:[MiniUITableGroupCellBackgroudView class]] )
    {
        view = [[MiniUITableGroupCellBackgroudView alloc] initWithFrame:CGRectZero];
        if (backgroundCorlor != nil )
        view.backgroundColor = backgroundCorlor;
        view.borderColor = tableView.separatorColor;
        self.backgroundView = view;
    }
    else
    {
        view = (MiniUITableGroupCellBackgroudView *)self.backgroundView;
    }
    
    if ( view != nil )
    {
        view.loc = loc;
        view = nil;
    }
    
    if ( self.selectedBackgroundView == nil || ![self.selectedBackgroundView isKindOfClass:[MiniUITableGroupCellBackgroudView class]])
    {
        view = [[MiniUITableGroupCellBackgroudView alloc] initWithFrame:self.bounds];
         if (highlightedBackgroundCorlor != nil )
        view.backgroundColor = highlightedBackgroundCorlor;
        view.borderColor = tableView.separatorColor;
        self.selectedBackgroundView = view;
    }
    if ( view != nil )
    {
        view.loc = loc;
        view = nil;
    }
}

- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath background:(UIImage *)background highlightedBackground:(UIImage *)highlightedBackground sectionRowNumbers:(NSInteger)numberOfRow
{
    CGFloat imageW = background.size.width;
    CGFloat imageH = background.size.height;
    background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(imageH/2, imageW/2, imageH/2, imageW/2)];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:background];
    self.backgroundView = imageview;
    
    imageW = highlightedBackground.size.width;
    imageH = highlightedBackground.size.height;
    highlightedBackground = [highlightedBackground resizableImageWithCapInsets:UIEdgeInsetsMake(imageH/2, imageW/2, imageH/2, imageW/2)];
    UIImageView *highlightedImageView = [[UIImageView alloc] initWithImage:highlightedBackground];
    self.selectedBackgroundView = highlightedImageView;
}

@end
