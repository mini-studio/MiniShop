//
//  MRSignupInputTextField.h
//  HandFace
//
//  Created by Mini-Studio on 13-7-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniUIASTextField : UITextField

- (id)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView;

@property (nonatomic,strong)UIScrollView *scrollview;

@end
