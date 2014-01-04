//
//  MSFrameViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-30.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSFrameViewController.h"
#import "UIColor+Mini.h"

@interface MSFrameViewController ()
@property (nonatomic,strong)MSViewController *currentController;
@property (nonatomic,strong)MSViewController *preparedController;
@end

@implementation MSFrameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.subControllers = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviTitleViewShow:YES];
    self.naviTitleView.backgroundColor = NAVI_BG_COLOR;
    self.containerView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.containerView];
    [self.containerView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.containerView.pagingEnabled = YES;
    self.topTitleView = [self createNaviMenuAndSubControllers];
    [self.naviTitleView addSubview:self.topTitleView];
    self.containerView.alwaysBounceVertical = NO;
    self.containerView.showsHorizontalScrollIndicator = NO;
    self.containerView.showsVerticalScrollIndicator = NO;
    __PSELF__;
    [self.topTitleView setSelected:^(id userInfo) {
        NSInteger index = [userInfo integerValue];
        [pSelf setCurrentControllerWithIndex:index];
    }];
    self.containerView.contentSize = CGSizeMake(self.subControllers.count*self.contentView.width,0);
}

- (MSNaviMenuView*)createNaviMenuAndSubControllers
{
    MSNaviMenuView *topTitleView = [[MSNaviMenuView alloc] initWithFrame:CGRectMake(0, 0,self.naviTitleView.width-100,44)];
    return topTitleView;
}

- (void)setCurrentController:(MSViewController *)currentController
{
    if ( _currentController != nil ) {
        [_currentController deselectedAsChild];
    }
    _currentController = currentController;
    [_currentController selectedAsChild];
}

- (void)setCurrentControllerWithIndex:(NSInteger)index
{
    MSViewController *controller = [self.subControllers objectAtIndex:index];
    [self setCurrentController:controller];
    self.containerView.contentOffset = CGPointMake(index*self.containerView.width, 0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( self.subControllers.count==0)
    {
        return;
    }
    static CGPoint lastPoint;
    if ( [@"contentOffset" isEqualToString:keyPath] ) {
        CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        int page = point.x / self.containerView.width;
        if ( page * self.containerView.width == point.x ) {
            [self.topTitleView setSelectedIndex:page cascade:NO];
            MSViewController *controller = [self.subControllers objectAtIndex:page];
            [self setCurrentController:controller];
        }
        else {
            [self.topTitleView setSlidePercent:(point.x/self.containerView.contentSize.width) left:(point.x > lastPoint.x)];
        }
        lastPoint = point;
    }
}
@end
