//
//  MSUIWebViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIWebViewController.h"
#import "MSNWebViewToolBar.h"

@interface MSUIWebViewController ()
@property (nonatomic,strong)MSNWebViewToolBar *miniToolBar;
@property (nonatomic,strong)NSURLRequest *request;
@end

@implementation MSUIWebViewController

- (id)init
{
    if (self = [super init]) {
        [self registerBlock];
        _dismissWaitingDelay = 5.0;
    }
    return self;
}

- (id)initWithUri:(NSString *)uri title:(NSString *)title toolbar:(BOOL)toolbar
{
    self = [super init];
    if (self) {
        self.cTitle = title;
        self.uri = uri;
        self.toolbar = toolbar;
        [self registerBlock];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request title:(NSString *)title toolbar:(BOOL)toolbar
{
    self = [super init];
    if (self) {
        self.cTitle = title;
        self.request = request;
        self.toolbar = toolbar;
        [self registerBlock];
    }
    return self;
}

- (void)registerBlock
{
    __weak typeof (self) itSelf = self;
    [self setRequestObserverBlock:^BOOL(MiniUIWebViewController *controller, NSString *url,UIWebViewNavigationType navigationType) {
        return [itSelf handlerRequest:url navigationType:navigationType];
    }];
}

- (void)loadView
{
    [super loadView];
    if ( self.toolbar ) {
        _webView.height = _webView.height - 45;
        [self createToolBar];
    }
    if ( self.htmlStr.length > 0 ){
        [_webView loadHTMLString:self.htmlStr baseURL:nil];
    }
    else if ( self.uri.length > 0 ){
        [self loadURL:[NSURL URLWithString:self.uri]];
    }
    else if (self.request != nil) {
        [self loadRequest:self.request];
    }
}

- (void)createToolBar
{
    self.miniToolBar = [[MSNWebViewToolBar alloc] initWithFrame:CGRectMake(0, self.contentView.height - 45, self.contentView.width, 45)];
    self.miniToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.miniToolBar.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.miniToolBar.forwardButton addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.miniToolBar.reloadButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    
    self.miniToolBar.backButton.enabled = NO;
    self.miniToolBar.forwardButton.enabled = NO;
    [self.contentView addSubview:self.miniToolBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.rightRefresh) {
        [self addRightRefreshButtonToTarget:self action:@selector(refresh)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)handlerRequest:(__strong NSString *)url navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        NSRange storeDetailRange = [url rangeOfString:@"type=shop" options:NSRegularExpressionCaseInsensitive];
        if (storeDetailRange.location != NSNotFound) {
            MSUIWebViewController* nextView = [[MSUIWebViewController alloc] initWithUri:url title:@"店铺详情" toolbar:YES];
            [self.navigationController pushViewController:nextView animated:YES];
            return NO;
        }
        NSRange addCareRange = [url rangeOfString:@"pagepos=2" options:NSRegularExpressionCaseInsensitive];
        if (addCareRange.location != NSNotFound) {
            MSUIWebViewController* nextView = [[MSUIWebViewController alloc] initWithUri:url title:@"添加关注" toolbar:NO];
            nextView.rightRefresh = YES;
            [self.navigationController pushViewController:nextView animated:YES];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(__strong UIWebView *)webView
{
    [self resetWebButtons];
    if ( self.cTitle.length == 0 ) {
        NSString* title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
        self.naviTitleView.title = title;
    }
    double delayInSeconds = self.dismissWaitingDelay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissWating];
    });
}

- (void)webView:(__strong UIWebView *)webView didFailLoadWithError:(__strong NSError *)error
{
    [self resetWebButtons];
    [super webView:webView didFailLoadWithError:error];
}

- (void)resetWebButtons
{
    if ( self.miniToolBar == nil ) {
        return;
    }
    UIButton* backBtn = self.miniToolBar.backButton;
    UIButton* forwardBtn = self.miniToolBar.forwardButton;
    if (_webView.canGoBack){
        backBtn.enabled = YES;
    }
    else {
        backBtn.enabled = NO;
    }
    if (_webView.canGoForward) {
        forwardBtn.enabled = YES;
    }
    else {
        forwardBtn.enabled = NO;
    }
}

- (void)refresh
{
    [_webView reload];
}


- (void)goBack
{
    if (_webView.canGoBack) {
        [_webView goBack];
    }
}

- (void)goForward
{
    if (_webView.canGoForward) {
        [_webView goForward];
    }
}


@end
