//
//  MSGuideViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-24.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSGuideViewController.h"
#import "MSMainTabViewController.h"
#import "UIDevice+Ext.h"
#import "MiniUIImage.h"
#import "AppDelegate.h"
@interface MSGuideViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong)UIScrollView   *scrollView;
@property (nonatomic,strong)UIView    *textView;
@property (nonatomic,strong)UIImageView    *textImageView;
@property (nonatomic)NSInteger currentPage;
@property (nonatomic,strong)MiniUIButton *button;
//@property (nonatomic,strong)UIPageControl  *pageControl;
@end


@implementation MSGuideViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat centerX = (CGRectGetMinX(_scrollView.bounds) + CGRectGetMaxX(_scrollView.bounds))/2.0f;
    //self.pageControl.currentPage = centerX / CGRectGetWidth(_scrollView.bounds);
    NSInteger page = centerX / CGRectGetWidth(_scrollView.bounds);
    [self scrollToPage:page];
}

-(void)pageChanged:(id)sender
{
    UIPageControl* control = (UIPageControl*)sender;
    NSInteger page = control.currentPage;
    CGFloat left = page * self.scrollView.width;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(left, 0);
    }];
}

- (void)scrollToPage:(NSInteger)page
{
    if ( page != self.currentPage )
    {
        CGFloat duration = self.currentPage == -1 ? 0 : 0.5;
        self.currentPage = page;
        self.textView.alpha = 1.0f;
        [UIView animateWithDuration:duration animations:^{
            self.textView.alpha = 0.05f;
        } completion:^(BOOL finished) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_b%d_txt",page+1]];
            self.textImageView.size = image.size;
            CGFloat centerY = 0;
            if ( page == 4 )
            {
                if ( IS_IPHONE5 )
                {
                    centerY = (self.textView.height-40)/2;
                }
                else
                {
                    centerY = image.size.height/2;
                }
                self.button.hidden = NO;
                self.textView.userInteractionEnabled = YES;
            }
            else
            {
                centerY = self.textView.height/2;
                self.button.hidden = YES;
                self.textView.userInteractionEnabled = NO;
            }
            self.textImageView.center = CGPointMake(self.textView.width/2, centerY);
            self.textImageView.image = image;
            [UIView animateWithDuration:duration animations:^{
                self.textView.alpha = 1.0f;
            }];
        }];
    }
}

- (void)loadView
{
    [super loadView];
    self.currentPage = -1;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[MiniUIImage imagePreciseNamed:@"guide_bg" ext:@"png"]];
    [self.view addSubview:imageView];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.frame = [self.view bounds];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    NSInteger num = 5;
    CGFloat top = 20;
    CGFloat scale = 0.7;
    CGFloat textViewTop = 100;
    CGFloat buttonBottom = 23;
    CGFloat textViewHeight = 100;
    if ( IS_IPHONE5 )
    {
        top = 60;
        scale = 1;
        textViewTop = 160;
        textViewHeight = 140;
    }
    for ( NSInteger index = 0; index < num; index++ )
    {
        NSString *imageName = [NSString stringWithFormat:@"guide_b%d",index+1];
        UIImage *image = [MiniUIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.center = CGPointMake(index*self.scrollView.width + self.scrollView.width/2, imageView.height/2 + top);
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * num , self.scrollView.height);
    self.textView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-textViewTop, self.view.width, textViewHeight)];
    self.textView.userInteractionEnabled = NO;
    [self.view addSubview:self.textView];
    self.textImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.textView addSubview:self.textImageView];
    [self scrollToPage:0];
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"guide_btn_normal"] highlightedImage:[UIImage imageNamed:@"guide_btn_selected"]];
    button.size = CGSizeMake(button.size.width*scale, button.size.height*scale);
    button.center = CGPointMake(self.textView.width/2,self.textView.height - buttonBottom);
    button.hidden = YES;
    self.button = button;
    [self.textView addSubview:button];
    __PSELF__;
    [button setTouchupHandler:^(MiniUIButton *button) {
        [pSelf actionForloadMainController];
    }];
}

- (void)actionForloadMainController
{
    [(AppDelegate*)[UIApplication sharedApplication].delegate loadMainController];
}

@end
