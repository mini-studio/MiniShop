//
//  MSMainViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSMainTabViewController.h"
#import "MSSettingsViewController.h"
#import "MSNofiViewController.h"
#import "MSStoreViewController.h"
#import "MSProfileViewController.h"
#import "MSMiniUINavigationController.h"
#import "MSTopicViewController.h"
#import "UIColor+Mini.h"
#import "MSDefine.h"
#import "MSSystem.h"
#import "MyStoreViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface MSTabBarView : MiniUITabBar

@end

@implementation MSTabBarView

- (void)layoutFloatingImageView:(CGFloat)width
{
    highLightImageView.width = width;
    highLightImageView.height = self.height - 1.7;
    highLightImageView.left = [self bottomHighlightImageXAtIndex:selectedTabIndex];
    highLightImageView.top = 1.7;
}

- (void)setTabBackImage:(UIImage *)tabBg
{
    UIImageView *tab = (UIImageView *)[self viewWithTag:0x110];
    UIImage *tabBackImg = tabBg;
    if ( tabBackImg.size.width < 20 )
    {
        tabBackImg = [tabBackImg stretchableImageWithLeftCapWidth:ceil(tabBackImg.size.width/2) topCapHeight:ceil(tabBackImg.size.height/2)];
    }
    tab.image = tabBackImg;
    tab.frame = self.bounds;
}

- (CGFloat)bottomHighlightImageXAtIndex:(NSUInteger)tabIndex
{
	CGFloat tabItemWidth = ceil(self.frame.size.width / self.tabItemsArray.count);
	return (tabIndex * tabItemWidth);
}

@end

@interface MSMainTabViewController ()<MiniUITabBarControllerDelegate>
@property (nonatomic,strong) NSDictionary *tableItemAttri;
@property (nonatomic,strong) UILabel      *notiLabel;
@end

@implementation MSMainTabViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.controllerDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkEvent:) name:MSNetWorkErrorNitification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSInteger)heightForTabBarView
{
    return 46;
}

- (NSDictionary *)tableBarItemAttriAtIndex:(NSInteger)index
{
    return self.tableItemAttri;
}

- (MiniUITabBar *)tabBarView
{
    if ( tabBarView == nil )
    {
        tabBarView = [[MSTabBarView alloc] init];
    }
    
    return tabBarView;
}


- (void)loadView
{
    [super loadView];
    self.tableItemAttri = @{@"titleFontHeight":@"10",@"highLightTitleColor":[UIColor colorWithRGBA:0xFFFFFF88],@"titleColor":[UIColor colorWithRGBA:0xFFFFFF99]};
    [self.tabBarView setTabBackImage:[MiniUIImage imageNamed:@"tab_background"]];
    [self.tabBarView setTabItemHighlightImage:[MiniUIImage imageNamed:@"tab_slider"]];
    self.items = [NSArray arrayWithObjects:
                  [[MiniTabBarItem alloc] initWithControllerClass:[MyStoreViewController class] image:[MiniUIImage imageNamed:@"tab_storenews_normal"] highlightedImage:[MiniUIImage imageNamed:@"tab_storenews_selected"] title:@"我的商城"],
                   [[MiniTabBarItem alloc] initWithControllerClass:[MSTopicViewController class] image:[MiniUIImage imageNamed:@"tab_market_normal"] highlightedImage:[MiniUIImage imageNamed:@"tab_market_selected"] title:@"闲逛"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSStoreViewController class] image:[MiniUIImage imageNamed:@"tab_storemanage_normal"] highlightedImage:[MiniUIImage imageNamed:@"tab_storemanage_selected"] title:@"发现"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSProfileViewController class] image:[MiniUIImage imageNamed:@"tab_mine_normal"] highlightedImage:[MiniUIImage imageNamed:@"tab_mine_selected"] title:@"我的"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSSettingsViewController class] image:[MiniUIImage imageNamed:@"tab_helper_normal"] highlightedImage:[MiniUIImage imageNamed:@"tab_helper_selected"] title:@"更多"],
                  nil];
}

- (UIImage *)navigationBarBackGroundForIndex:(NSInteger)index
{
    UIImage *image = [MiniUIImage imageNamed:([MSSystem sharedInstance].mainVersion >= 7?@"navi_background":@"navi_background")];
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, 0, image.size.height/2, 0)];
    return image;
}

- (Class)naviControllerClass
{
    return [MSMiniUINavigationController class];
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

- (BOOL)willSelectedAtIndex:(NSInteger)index
{
    return NO;
}
- (void)willDeselectedAtIndex:(NSInteger)index
{
    
}
- (void)didSelectedAtIndex:(NSInteger)index
{
    if ( index == 1 )
    {
        [MobClick event:MOB_STORE_TAB];
    }
}
- (void)didDeselectedAtIndex:(NSInteger)index
{
    
}

- (void)handleNetworkEvent:(NSNotification *)noti
{
    if ( self.notiLabel == nil )
    {
        self.notiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
        self.notiLabel.backgroundColor = [UIColor colorWithRGBA:0x000000CC];
        self.notiLabel.textColor = [UIColor colorWithRGBA:0xEEEEEEFF];
        self.notiLabel.font = [UIFont systemFontOfSize:16];
        self.notiLabel.text = @"网络不给力!!!";
        self.notiLabel.textAlignment = NSTextAlignmentCenter;
        self.notiLabel.centerY = self.view.height/2;
        self.notiLabel.layer.cornerRadius = 4;
        self.notiLabel.layer.masksToBounds = YES;
    }
    self.notiLabel.left = self.view.width;
    [self.view addSubview:self.notiLabel];
    [UIView animateWithDuration:0.6  delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{        
    self.notiLabel.right = self.view.width+4;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
           self.notiLabel.left = self.view.width; 
        } completion:^(BOOL finished) {
            [self.notiLabel removeFromSuperview];
        }];
    }];
}

@end
