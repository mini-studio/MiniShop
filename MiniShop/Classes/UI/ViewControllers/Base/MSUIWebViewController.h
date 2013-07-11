//
//  MSUIWebViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MiniUIWebViewController.h"

@interface MSUIWebViewController : MiniUIWebViewController
@property (nonatomic,strong) NSString *uri;
@property (nonatomic,strong) NSString *htmlStr;
@property (nonatomic)CGFloat dismissWaitingDelay;
@property (nonatomic)BOOL rightRefresh;
@property (nonatomic)BOOL toolbar;
- (id)initWithUri:(NSString *)uri title:(NSString *)title toolbar:(BOOL)toolbar;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
@end
