//
//  MRSignupInputTextField.m
//  HandFace
//
//  Created by Mini-Studio on 13-7-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniUIASTextField.h"

@interface MiniUIASTextField()
@property (nonatomic) CGPoint offset;
@property (nonatomic) BOOL keyBorderShowing;
@property (nonatomic) CGRect keyborderFrame;
@end

@implementation MiniUIASTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyBorderWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyBorderWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self resetOffsetTrace];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView
{
    self = [self initWithFrame:frame];
    if ( self )
    {
        self.scrollview = scrollView;
    }
    return self;
}

- (void)scroollToVisible
{
    UIWindow *window = ([UIApplication sharedApplication].delegate).window;
    CGRect frame = [self.superview convertRect:self.frame toView:window];
    frame.origin.y += 10;
    CGFloat maxY = CGRectGetMaxY(frame);
    if( maxY > self.keyborderFrame.origin.y ) //below keyborder
    {
        CGPoint offset = self.scrollview.contentOffset;
        offset.y += (maxY - self.keyborderFrame.origin.y);
        [UIView animateWithDuration:0.30F animations:^{
            self.scrollview.contentOffset = offset;
        }completion:^(BOOL finished) {
        }];
    }
    else if ( frame.origin.y < 80 )
    {
        CGPoint offset = self.scrollview.contentOffset;
        offset.y += (maxY - (self.keyborderFrame.origin.y - 20));
        [UIView animateWithDuration:0.30F animations:^{
            self.scrollview.contentOffset = offset;
        }completion:^(BOOL finished) {
        }];
    }
}

- (void)handleKeyBorderWillShow:(NSNotification *)noti
{
    CGRect keyborderFrame = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyborderFrame = keyborderFrame;
    if ( [self isFirstResponder] )
    {
        [self scroollToVisible];
    }
     self.keyBorderShowing = YES;
}

- (void)handleKeyBorderWillHide:(NSNotification *)noti
{
    self.keyBorderShowing = NO;
    if ( self.offset.y != MAXFLOAT )
    {
        [UIView animateWithDuration:0.25f animations:^{
            self.scrollview.contentOffset = self.offset;
        }];
    }
    [self resetOffsetTrace];
}

- (BOOL)becomeFirstResponder
{
    if ( self.keyBorderShowing )
    {
        [self scroollToVisible];
    }
    else
    {
         self.offset = self.scrollview.contentOffset;
    }
    return [super becomeFirstResponder];
}


- (void)resetOffsetTrace
{
    self.offset = CGPointMake(0,MAXFLOAT);
}


@end
