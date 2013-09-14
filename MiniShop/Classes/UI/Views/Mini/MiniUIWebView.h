//
//  MiniUIWebView.h
//  bake
//
//  Created by Wuquancheng on 12-10-27.
//  Copyright (c) 2012年 youlu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniUIWebView : UIWebView

@property (nonatomic)BOOL miniReq;

- (void)loadFile:(NSString *)fileName ofType:(NSString *)type;

- (void)resetDelegate:(id<UIWebViewDelegate>)delegate;

- (void)setViewBackgroundColor:(UIColor *)backgroundColor;

@end
