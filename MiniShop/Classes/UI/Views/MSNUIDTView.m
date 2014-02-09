//
//  MSNUIDTView.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-14.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNUIDTView.h"
@interface MSNUIDTView()<UIWebViewDelegate>
@property (nonatomic,strong) UIPanGestureRecognizer *recognizer;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic) CGPoint lastTranslation;
@property (nonatomic,strong) NSString *lastRequestURL;
@property (nonatomic,strong) MiniUIButton *closeButton;
@end

@implementation MSNUIDTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.webView = [[MiniUIWebView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:self.webView];
        self.backgroundColor = [UIColor whiteColor];
        self.closeButton = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"closep"] highlightedImage:[UIImage imageNamed:@"closep"]];
        self.closeButton.center = CGPointMake( self.width-self.closeButton.width/2-10, self.closeButton.height/2 + 10);
        [self addSubview:self.closeButton];
        [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
//        self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
//        [self.webView.scrollView addGestureRecognizer:self.recognizer];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.recognizer];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer == self.recognizer )
    return NO;
    else return NO;
}

- (void)handelPan:(UIPanGestureRecognizer *)recognizer
{
//    CGPoint translation = [recognizer translationInView:self];
   
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            // self.lastTranslation = translation;
            break;
        }
        case UIGestureRecognizerStateChanged: {
//            self.lastTranslation = translation;
//            CGFloat top = self.top;
//            top += translation.y;
//            self.top = top;
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
//            CGFloat top = self.bestTop;
//            if ( self.top > self.bestTop + 50 && self.lastTranslation.y > 0 )  {
//                top = self.superview.height-self.toolbar.height;
//            }
//            else if ( (self.top < (self.superview.height-self.toolbar.height) - 50) && (self.lastTranslation.y < 0)) {
//                top = self.bestTop;
//            }
//            [UIView animateWithDuration:0.25 animations:^{
//                self.top = top;
//            }];
            break;
        }
        default:
            break;
    }
 //   [recognizer setTranslation:CGPointZero inView:self];
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
    [self bringSubviewToFront:self.closeButton];
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
        if ( point.y < -60 ) {
            if ( self.delegate && [self.delegate respondsToSelector:@selector(hideDTView)] ) {
                [self.delegate performSelectorInBackground:@selector(hideDTView) withObject:nil];
            }
        }
        else {
            self.toolbar.top = 0;
        }
    }
}

- (void)loadDetail
{
    [MobClick event:MOB_DETAIL_PULL];
    NSString *url =[NSString stringWithFormat:@"http://www.youjiaxiaodian.com/new/showgoodsdescimage?screenY=960&screenW=640&id=%@",self.mid];
    if ( ![url isEqualToString:self.lastRequestURL] ) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
        [_webView loadRequest:request];
    }
    self.lastRequestURL=url;
    LOG_DEBUG(@"Load detail %@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[ClientAgent sharedInstance] perfectHttpRequest:request];
    [self.webView loadRequest:request];

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

- (void)close
{
    if ( self.delegate && [self.delegate respondsToSelector:@selector(hideDTView)] ) {
        [self.delegate performSelectorInBackground:@selector(hideDTView) withObject:nil];
    }
}

@end
