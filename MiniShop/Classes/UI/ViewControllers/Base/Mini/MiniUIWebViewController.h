//
//  MiniUIWebViewController.h
//  bake
//
//  Created by Wuquancheng on 12-10-28.
//  Copyright (c) 2012年 youlu. All rights reserved.
//

#import "MiniViewController.h"
#import "MSViewController.h"
#import "MiniUIWebView.h"

@interface MiniUIWebViewController : MSViewController
{
    MiniUIWebView *_webView;
}

@property (nonatomic)BOOL miniReq;
@property (nonatomic,strong)NSString *ctitle;
@property (nonatomic)BOOL autoLayout;
@property (nonatomic)BOOL defaultBackButton;
@property (nonatomic,strong)NSString *content;

- (void)loadContent:(NSString*)content title:(NSString*)title;

- (void)loadFile:(NSString *)fileName ofType:(NSString *)type title:(NSString *)title;

- (void)setRequestObserverBlock:(BOOL (^)(MiniUIWebViewController *controller, NSString *url, UIWebViewNavigationType navigationType))block;

- (void)loadURL:(NSURL*)url;

- (void)loadRequest:(NSURLRequest*)request;

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end
