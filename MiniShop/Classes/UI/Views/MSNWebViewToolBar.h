//
//  FBWebViewToolBar.h
//  FullBloom
//
//  Created by 董蕾 on 13-3-3.
//  Copyright (c) 2013年 simo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNWebViewToolBar : UIImageView
{
    UIImageView*    _buttonForderImageView;
    
    UIButton*   _backButton;
    UIButton*   _forwardButton;
    UIButton*   _reloadButton;
}

@property (nonatomic, strong) UIButton*   backButton;
@property (nonatomic, strong) UIButton*   forwardButton;
@property (nonatomic, strong) UIButton*   reloadButton;

@end
