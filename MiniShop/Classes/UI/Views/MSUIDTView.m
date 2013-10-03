//
//  MSUIDTView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-14.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIDTView.h"
@interface MSUIDTView()<UIWebViewDelegate>
@property (nonatomic,strong) UIPanGestureRecognizer *recognizer;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic) CGPoint lastTranslation;
@end

@implementation MSUIDTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
        [self addGestureRecognizer:self.recognizer];
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.recognizer];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)handelPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
   
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
             self.lastTranslation = translation;
            if ( translation.y < 0 ) {
                [self loadDetail];
            }
        }
        case UIGestureRecognizerStateChanged: {
             self.lastTranslation = translation;
            CGFloat top = self.top;
            top += translation.y;
            self.top = top;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat top = self.bestTop;
            if ( self.top > self.bestTop + 50 && self.lastTranslation.y > 0 )  {
                top = self.superview.height-self.toolbar.height;
            }
            else if ( (self.top < (self.superview.height-self.toolbar.height) - 50) && (self.lastTranslation.y < 0)) {
                top = self.bestTop;
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.top = top;
            }];
        }
        default:
            break;
    }
    [recognizer setTranslation:CGPointZero inView:self];
}

- (void)setToolbar:(UIView *)toolbar
{
    _toolbar = toolbar;
    [self addSubview:toolbar];
}

- (void)setWebView:(MiniUIWebView *)webView
{
    _webView = webView;
    _webView.scalesPageToFit = YES;
    [self addSubview:_webView];
    [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_webView setViewBackgroundColor:[UIColor clearColor]];
    [_webView setDelegate:self];
}

- (void)loadurl:(NSString*)url
{
    LOG_DEBUG( @"%@", url );
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [@"contentOffset" isEqualToString:keyPath] && object==self.webView.scrollView ) {
        CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if ( point.y < 0 ) {
            self.toolbar.top = -point.y;
            if ( self.toolbar.top > 50 ) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.top = self.superview.height-self.toolbar.height;
                    self.toolbar.top = 0;
                }];
            }
        }
        else {
            self.toolbar.top = 0;
        }
    }
}

- (void)loadDetail
{
    NSString *url =[NSString stringWithFormat:@"http://www.youjiaxiaodian.com/api/showgoodsdescimage?screenY=960&screenW=640&id=%lld",self.mid];
    url = [ClientAgent prefectUrl:url];
    LOG_DEBUG(@"Load detail %@",url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.indicator.center = CGPointMake(_webView.width/2, _webView.height/2);
    [_webView addSubview:self.indicator];
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
}

@end
