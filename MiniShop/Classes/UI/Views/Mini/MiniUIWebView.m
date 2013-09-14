//
//  MiniUIWebView.m
//  bake
//
//  Created by Wuquancheng on 12-10-27.
//  Copyright (c) 2012年 youlu. All rights reserved.
//

#import "MiniUIWebView.h"
#import "UIColor+Mini.h"
#import "MiniSysUtil.h"
#import "MiniUIWebViewController.h"
#import "NSString+URLEncoding.h"


@interface MiniUIWebView ()<UIWebViewDelegate>
@property (nonatomic,assign) id<UIWebViewDelegate> proxy;
@end

@implementation MiniUIWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self clear];
        self.miniReq = YES;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.delegate  = self;
        self.scalesPageToFit = YES;
    }
    return self;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    if ( delegate == self )
    {
        [super setDelegate:self];
    }
    else
    {
        self.proxy = delegate;
    }
}

- (void)resetDelegate:(id<UIWebViewDelegate>)delegate
{
    [super setDelegate:delegate];
    self.proxy = nil;
}

- (void)clear
{
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)aView setShowsVerticalScrollIndicator:NO]; //右侧的滚动条 （水平的类似） d
            aView.backgroundColor = [UIColor whiteColor];
            for (UIView *shadowView in aView.subviews)
            {
                if ([shadowView isKindOfClass:[UIImageView class]])
                {
                    shadowView.hidden = YES;  //上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                }
                
            }
        }
    }
}

- (void)setViewBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIScrollView class]])
        {
            aView.backgroundColor = backgroundColor;
        }
    }
}

- (void)loadFile:(NSString *)fileName ofType:(NSString *)type
{
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self loadHTMLString:html baseURL:baseURL];
}


- (BOOL)webView:(__strong UIWebView *)webView shouldStartLoadWithRequest:(__strong NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = [[request URL] absoluteString];
    if ( [url hasPrefix:@"tel:"] )
    {
        [MiniSysUtil call:[url substringFromIndex:@"tel:".length]];
        return NO;
    }
    else if ( [url hasPrefix:@"mailto:"] )
    {
        [[MiniSysUtil sharedInstance] sendEmail:@"" subject:@"" ToRecipients:@[[url substringFromIndex:@"mailto:".length]] CcRecipients:nil viewController:(UIViewController*)self.proxy block:nil];
        return NO;
    }
    else if ( [url hasPrefix:@"minihttp:"])
    {
        MiniUIWebViewController *controller = [[MiniUIWebViewController alloc] init];
        controller.miniReq = NO;
        [((UIViewController*)self.proxy).navigationController pushViewController:controller animated:YES];
        [controller loadURL:[NSURL URLWithString:[url substringFromIndex:@"mini".length]]];
        return NO;
    }
    else
    {
        if ( self.proxy && [self.proxy respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        {
            return [self.proxy webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
        else
        {
            return YES;
        }
    }
}

- (void)webViewDidStartLoad:(__strong UIWebView *)webView
{
    if ( self.proxy && [self.proxy respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.proxy webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(__strong UIWebView *)webView
{
    if ( self.proxy && [self.proxy respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.proxy webViewDidFinishLoad:webView];
    }
}

- (void)webView:(__strong UIWebView *)webView didFailLoadWithError:(__strong NSError *)error
{
    if ( self.proxy &&[self.proxy respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.proxy webView:webView didFailLoadWithError:error];
    }
}

@end
