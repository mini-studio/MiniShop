//
//  MSUIAuthWebViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIAuthWebViewController.h"
#import "MSSystem.h"

@interface MSUIAuthWebViewController ()

@end

@implementation MSUIAuthWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    [self dismissWating:nil];
    NSString* title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
    if ( [@"taobao_callback_ok" isEqualToString:title] || [title rangeOfString:@"成功"].location != NSNotFound) {
        [MSSystem sharedInstance].version.auth = 1;
        if ( self.callback != nil ) {
            self.callback( YES );
        }
    }
    else {
        self.naviTitleView.title = title;
    }
}

- (void)webView:(__strong UIWebView *)webView didFailLoadWithError:(__strong NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    [self dismissWating];
}

- (BOOL)webView:(__strong UIWebView *)webView shouldStartLoadWithRequest:(__strong NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self showWating:nil];
    return YES;
}

- (void)back
{
     if ( self.callback != nil ) {
         self.callback(NO);
     }
     else {
         [super back];
     }
}

@end
