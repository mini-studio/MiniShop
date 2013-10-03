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
@end

@implementation MiniUIWebViewController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
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
    self.navigationItem.title = self.ctitle;
    if ( self.autoLayout )
    {
        _webView = [[MiniUIWebView alloc] initWithFrame:self.view.bounds];
    }
    else
    {
        if ( MAIN_VERSION >= 7 ) {
            _webView = [[MiniUIWebView alloc] initWithFrame:self.view.bounds];
        }
        else {
        CGFloat offsetY = self.navigationController.navigationBar.height;
       _webView = [[MiniUIWebView alloc] initWithFrame:CGRectMake(0, offsetY, self.view.width, self.view.height-offsetY)];
        }
    }
    _webView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    
    _webView.miniReq = self.miniReq;
    
    [self.view addSubview:_webView];
    if ( self.fileName != nil )
    {
      [_webView loadFile:self.fileName ofType:self.fileType];
        self.navigationItem.title = self.ctitle;
    }
    [self setNaviBackButton];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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

- (void)loadFile:(NSString *)fileName ofType:(NSString *)type title:(NSString *)title;
{
    if ( _webView != nil )
    {
       [_webView loadFile:fileName ofType:type];
       self.navigationItem.title = title;
    }
    else
    {
        self.fileName = fileName;
        self.ctitle = title;
        self.fileType = type;
    }
}

- (void)setRequestObserverBlock:(BOOL (^)(MiniUIWebViewController *controller, NSString *url, UIWebViewNavigationType navigationType))block
{ 
    requestObserver =  block ;
}


- (BOOL)webView:(__strong UIWebView *)webView shouldStartLoadWithRequest:(__strong NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissWating) userInfo:nil repeats:NO];
    if ( !self.miniReq )
    {
        [self showWating:nil];
        return YES;
    }
    if ( requestObserver )
    {
        return requestObserver(self,request.URL.absoluteString,navigationType);
    }
    else
    {
        [self showWating:nil];
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
    [self showWating:nil];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    _webView.miniReq = NO;
}


- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    if ( self.defaultBackButton ) {
        return [super navLeftButtonWithTitle:title target:target action:action];
    }
    else {
        MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"close"] highlightedImage:[UIImage imageNamed:@"close_h"]];
        button.width += 14;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        button.showsTouchWhenHighlighted = YES;
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        tmpBarButtonItem.style = UIBarButtonItemStyleBordered;
        
        return  tmpBarButtonItem;
    }
}

- (void)showWating:(NSString *)message
{
    //[super showWating:message];
    self.indicatorView.center = CGPointMake(self.view.width/2, self.view.height/2);
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    //self.view.userInteractionEnabled = YES;
}

- (void)dismissWating:(BOOL)animated
{
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
}

- (void)HandleStartWebREQ:(NSNotification *)noti
{
    dispatch_block_t __block__ = ^{
        [self showWating:nil];
        [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissWating) object:nil];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissWating) userInfo:nil repeats:NO];
    };
    if ( [[NSThread currentThread] isMainThread] ) {
        __block__();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            __block__();
        });
    }
    
}

- (void)HandleEndWebREQ:(NSNotification *)noti
{
    if ( [[NSThread currentThread] isMainThread] ) {
        [self dismissWating];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self dismissWating];
        });
    }
}


@end
