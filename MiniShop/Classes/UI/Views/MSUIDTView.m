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
@end

@implementation MSUIDTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
        //[self addGestureRecognizer:self.recognizer];
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
            if ( translation.y < 0 ) {
                [self loadDetail];
            }
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat top = self.top;
            top += translation.y;
            self.top = top;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat top = self.bestTop;
            if ( self.top > self.superview.height/2 ) {
                top = self.superview.height-self.toolbar.height;
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
    NSString *url =[NSString stringWithFormat:@"http://www.youjiaxiaodian.com/api/showgoodsdescimage?screenY=960&screenW=640&imei=%@&id=%lld",UDID,self.mid];
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
