//
//  MiniUIWebViewController.m
//  bake
//
//  Created by Wuquancheng on 12-10-28.
//  Copyright (c) 2012年 youlu. All rights reserved.
//

#import "MiniUIWebViewController.h"
#import "MiniUIWebView.h"


@interface MiniUIWebViewController ()<UIWebViewDelegate>
{
    NSString *_fileName;
    NSString *_fileType;    
    BOOL (^requestObserver)(MiniUIWebViewController *controller, NSString *url, UIWebViewNavigationType navigationType);
}
@property (nonatomic,strong)NSString *fileName;
@property (nonatomic,strong)NSString *fileType;
@property (nonatomic,strong)UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong)UIActivityIndicatorView *bigIndicatorView;
@end

@implementation MiniUIWebViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _miniReq = YES;
        self.autoLayout = YES;
        self.defaultBackButton = NO;
    }
    return self;
}

- (void)setMiniReq:(BOOL)miniReq
{
    _miniReq = miniReq;
    _webView.miniReq = miniReq;
}


- (void)loadView
{
    [super loadView];
    self.naviTitleView.title = self.cTitle;
    if ( self.autoLayout )
    {
        _webView = [[MiniUIWebView alloc] initWithFrame:self.contentView.bounds];
    }
    else
    {
        if ( MAIN_VERSION >= 7 ) {
            _webView = [[MiniUIWebView alloc] initWithFrame:self.contentView.bounds];
        }
        else {
        CGFloat offsetY = self.navigationController.navigationBar.height;
       _webView = [[MiniUIWebView alloc] initWithFrame:CGRectMake(0, offsetY, self.contentView.width, self.contentView.height-offsetY)];
        }
    }
    _webView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    
    _webView.miniReq = self.miniReq;
    
    [self.contentView addSubview:_webView];
    if ( self.fileName != nil ) {
      [_webView loadFile:self.fileName ofType:self.fileType];
        self.naviTitleView.title = self.cTitle;
    }
    else if (self.content != nil) {
        [_webView loadHTMLString:self.content baseURL:nil];
    }
    [self setNaviBackButton];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.bigIndicatorView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.bigIndicatorView.hidden = YES;
    [self.navigationController.navigationBar addSubview:self.bigIndicatorView];
    self.bigIndicatorView.center = CGPointMake(self.navigationController.navigationBar.width-self.bigIndicatorView.width, self.navigationController.navigationBar.height/2);
}

- (void)setNaviBackButton
{
    [super setNaviBackButton];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HandleStartWebREQ:) name:@"START_WEB_RQ" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HandleEndWebREQ:) name:@"END_WEB_RQ" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissWating];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"START_WEB_RQ" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"END_WEB_RQ" object:nil];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContent:(NSString*)content title:(NSString*)title
{
    self.content = content;
    self.cTitle = title;
}

- (void)loadFile:(NSString *)fileName ofType:(NSString *)type title:(NSString *)title;
{
    if ( _webView != nil )
    {
       [_webView loadFile:fileName ofType:type];
       self.naviTitleView.title = title;
    }
    else
    {
        self.fileName = fileName;
        self.cTitle = title;
        self.fileType = type;
    }
}

- (void)setRequestObserverBlock:(BOOL (^)(MiniUIWebViewController *controller, NSString *url, UIWebViewNavigationType navigationType))block
{ 
    requestObserver =  block ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self dismissWating:nil];
    __PSELF__;
    NSString* title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
    if (title.length>0) {
       pSelf.naviTitleView.title = title;
    }
}


- (BOOL)webView:(__strong UIWebView *)webView shouldStartLoadWithRequest:(__strong NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissWating) userInfo:nil repeats:NO];
    if ( !self.miniReq )
    {
        if ([request.URL.absoluteString hasPrefix:@"http"]) {
            [self showWating:nil];
        }
        return YES;
    }
    if ( requestObserver )
    {
        return requestObserver(self,request.URL.absoluteString,navigationType);
    }
    else
    {
        if ([request.URL.absoluteString hasPrefix:@"http"]) {
            [self showWating:nil];
        }
        return YES;
    }
}


- (void)webView:(__strong UIWebView *)webView didFailLoadWithError:(__strong NSError *)error
{
    [self dismissWating];
    if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorCannotConnectToHost)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MSNetWorkErrorNitification object:nil];
    }
}

- (void)loadURL:(NSURL*)url
{
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadRequest:(NSURLRequest*)request
{
    [self showWating:nil];
    [_webView loadRequest:request];
     _webView.miniReq = NO;
}

- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    if ( self.defaultBackButton ) {
        return [super navLeftButtonWithTitle:title target:target action:action];
    }
    else {
        MiniUIButton *button = [self naviRightButton];
        button.width += 14;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        button.showsTouchWhenHighlighted = YES;
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        tmpBarButtonItem.style = UIBarButtonItemStyleBordered;
        
        return  tmpBarButtonItem;
    }
}

- (MiniUIButton*)naviRightButton
{
    return [MiniUIButton buttonWithImage:[UIImage imageNamed:@"close"] highlightedImage:[UIImage imageNamed:@"close_h"]];
}

- (void)showWating:(NSString *)message
{
    //[super showWating:message];
    self.indicatorView.center = CGPointMake(self.contentView.width/2, self.contentView.height/2);
    [self.contentView addSubview:self.indicatorView];
    if ( ![self.indicatorView isAnimating] )
    [self.indicatorView startAnimating];
    //self.contentView.userInteractionEnabled = YES;
    self.bigIndicatorView.hidden = NO;
    if ( ![self.bigIndicatorView isAnimating] )
    [self.bigIndicatorView startAnimating];
}

- (void)dismissWating:(BOOL)animated
{
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    self.bigIndicatorView.hidden = YES;
    [self.bigIndicatorView stopAnimating];
}

- (void)startWebRequest
{
    [self showWating:nil];
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissWating) object:nil];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissWating) userInfo:nil repeats:NO];
}

- (void)HandleStartWebREQ:(NSNotification *)noti
{
    if ( [[NSThread currentThread] isMainThread] ) {
        [self startWebRequest];
    }
    else {
        [self performSelector:@selector(startWebRequest) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES modes:nil];
    }
}

- (void)HandleEndWebREQ:(NSNotification *)noti
{
    if ( [[NSThread currentThread] isMainThread] ) {
        [self dismissWating];
    }
    else {
        [self performSelector:@selector(dismissWating) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES modes:nil];
    }
}


@end
