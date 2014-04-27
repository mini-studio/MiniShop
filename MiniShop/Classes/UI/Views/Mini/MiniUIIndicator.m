//
//  Indicator.m
//  Spiner
//
//  Created by Wuquancheng on 13-6-17.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniUIIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface Indicator()
@end


@implementation Indicator
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 86)];
    if (self) {
        //self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-40)/2, 10, 40, 40)];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:12];
        for (int index = 9; index > 0; index--)
        {
            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading%d",index]]];
        }
        for (int index = 1; index <= 9; index++)
        {
            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading%d",index]]];
        }
        self.imageView.animationImages = array;
        [self addSubview:self.imageView];
        self.imageView.animationDuration = 1.5f;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+6, self.frame.size.width, 20)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.label];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = NO;
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
- (void)startAnimating
{
    _mAnimating = YES;
    self.hidden = NO;
    [self.imageView startAnimating];
}
- (void)stopAnimating
{
    _mAnimating = NO;
    self.hidden = YES;
    [self.imageView stopAnimating];

}
- (BOOL)isAnimating
{
    return _mAnimating;
}

- (void)setHidesWhenStopped:(bool)hidesWhenStopped
{
}

@end

@interface MiniUIActivityIndicatorView ()
@property (nonatomic,strong)Indicator *indicator;
@end

@implementation MiniUIActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        self.indicator = [[Indicator alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        self.indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.indicator];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setLabelText:(NSString *)labelText
{
    self.indicator.label.text = labelText;
}

- (void)showInView:(UIView *)view
{
    [self showInView:view userInterfaceEnable:NO];
}

- (void)showInView:(UIView *)view userInterfaceEnable:(BOOL)enable
{
    if ( self.superview != nil )
    {
        return;
    }
    self.frame = view.bounds;
    [view addSubview:self];
    view.userInteractionEnabled = enable;
    [self.indicator startAnimating];
    self.indicator.alpha = 0;
    [UIView animateWithDuration:0 animations:^{
        self.indicator.alpha = 1;
    }];
}

- (void)hide
{
    self.indicator.alpha = 1;
    self.superview.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.indicator.alpha = 0;
    } completion:^(BOOL finished) {
        [self.indicator stopAnimating];
        [self removeFromSuperview];
    }];
}

- (BOOL)showing
{
    return self.indicator.isAnimating;
}

@end