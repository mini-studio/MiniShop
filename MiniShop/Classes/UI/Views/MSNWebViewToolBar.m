//
//  FBWebViewToolBar.m
//  FullBloom
//
//  Created by 董蕾 on 13-3-3.
//  Copyright (c) 2013年 simo. All rights reserved.
//

#import "MSNWebViewToolBar.h"

@implementation MSNWebViewToolBar

const CGSize    KWebToolbarButtonForderSize = {300.0f, 41.0f};
const CGSize    KWebToolbarButtonSize = {30.0f, 25.0f};
const CGSize    KWebToolbarButtonSpace = {300.0f/3.0f, 41.0f};

@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize reloadButton = _reloadButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        self.image = [UIImage imageNamed:@"web_toolbar_bg_"];
        
        _buttonForderImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"web_toolbar_bg"]];
        _buttonForderImageView.userInteractionEnabled = YES;
        [self addSubview:_buttonForderImageView];
        
        //后退
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"web_toolbar_btn_left_normal"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"web_toolbar_btn_left_normal"] forState:UIControlStateHighlighted];
        [_backButton setImage:[UIImage imageNamed:@"web_toolbar_btn_left_disable"] forState:UIControlStateDisabled];
        [_backButton setShowsTouchWhenHighlighted:YES];
        [_buttonForderImageView addSubview:_backButton];
        
        //前进
        _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forwardButton setImage:[UIImage imageNamed:@"web_toolbar_btn_right_normal"] forState:UIControlStateNormal];
        [_forwardButton setImage:[UIImage imageNamed:@"web_toolbar_btn_right_normal"] forState:UIControlStateHighlighted];
        [_forwardButton setShowsTouchWhenHighlighted:YES];
        [_forwardButton setImage:[UIImage imageNamed:@"web_toolbar_btn_right_disable"] forState:UIControlStateDisabled];
        [_buttonForderImageView addSubview:_forwardButton];
        
        //刷新
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadButton setImage:[UIImage imageNamed:@"web_toolbar_btn_refresh"] forState:UIControlStateNormal];
        [_reloadButton setImage:[UIImage imageNamed:@"web_toolbar_btn_refresh"] forState:UIControlStateHighlighted];
        [_reloadButton setShowsTouchWhenHighlighted:YES];
        [_buttonForderImageView addSubview:_reloadButton];
    }
    return self;
}

-(void)layoutSubviews
{
    CGRect buttonForderRect = CGRectInset(self.bounds, (self.bounds.size.width - KWebToolbarButtonForderSize.width)/2.0f, (self.bounds.size.height - KWebToolbarButtonForderSize.height)/2.0f);
    buttonForderRect.origin.y += 2;
    _buttonForderImageView.frame = buttonForderRect;
    
    CGRect backRect = CGRectZero;
    backRect.size = KWebToolbarButtonSpace;
    backRect = CGRectInset(backRect, (KWebToolbarButtonSpace.width - KWebToolbarButtonSize.width)/2.0f, (KWebToolbarButtonSpace.height - KWebToolbarButtonSize.height)/2.0f);
    _backButton.frame = backRect;
    
    CGRect forwardRect = CGRectOffset(backRect, KWebToolbarButtonSpace.width, 0);
    _forwardButton.frame = forwardRect;
    
    CGRect reloadRect = CGRectOffset(forwardRect, KWebToolbarButtonSpace.width, 0);
    _reloadButton.frame = reloadRect;
}

@end
