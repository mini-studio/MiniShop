//
//  MSMainViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSMainTabViewController.h"
#import "MSNSettingsViewController.h"
#import "MSMiniUINavigationController.h"
#import "UIColor+Mini.h"
#import "MSDefine.h"
#import "MSSystem.h"
#import "MSNStoreViewController.h"
#import "MSNFavViewController.h"
#import "MSNEspecialIndexViewController.h"
#import "MSNCreditableIndexViewController.h"
#import <QuartzCore/QuartzCore.h>


MSMainTabViewController *tabController=nil;

@interface MSTabBarView : MiniUITabBar

@end

@implementation MSTabBarView

- (void)layoutFloatingImageView:(CGFloat)width
{
    highLightImageView.width = width;
    highLightImageView.height = self.height - 1.7;
    highLightImageView.left = [self bottomHighlightImageXAtIndex:selectedTabIndex];
    highLightImageView.top = 2.4;
}

- (CGFloat)bottomHighlightImageXAtIndex:(NSUInteger)tabIndex
{
	CGFloat tabItemWidth = ceil(self.frame.size.width / self.tabItemsArray.count);
	return (tabIndex * tabItemWidth);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
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
        tabController = self;
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
    return 50;
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
    self.view.backgroundColor = nil;
    self.tableItemAttri = @{@"titleFontHeight":@"10",@"highLightTitleColor":[UIColor colorWithRGBA:0xC74761FF],
            @"titleColor":[UIColor colorWithRGBA:0xC74761FF],@"iconHeight":@"26",@"bottomSpace":@"2",@"iconTop":@"6"};
    //[self.tabBarView setTabBackImage:[MiniUIImage imageNamed:@"tab_background"]];
    //[self.tabBarView setTabItemHighlightImage:[MiniUIImage imageNamed:@"tab_slider"]];
    self.tabBarView.backgroundColor = [UIColor colorWithRGBA:0xf7eeefff];
    self.items = [NSArray arrayWithObjects:
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSNStoreViewController class] image:[MiniUIImage imageNamed:@"mymall"] highlightedImage:[MiniUIImage imageNamed:@"mymall_hover"] title:@"我的商城"],
                   [[MiniTabBarItem alloc] initWithControllerClass:[MSNEspecialIndexViewController class] image:[MiniUIImage imageNamed:@"sale"] highlightedImage:[MiniUIImage imageNamed:@"sale_hover"] title:@"广场"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSNCreditableIndexViewController class] image:[MiniUIImage imageNamed:@"shop"] highlightedImage:[MiniUIImage imageNamed:@"shop_hover"] title:@"好店汇"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSNFavViewController class] image:[MiniUIImage imageNamed:@"star"] highlightedImage:[MiniUIImage imageNamed:@"star_hover"] title:@"收藏夹"],
                  [[MiniTabBarItem alloc] initWithControllerClass:[MSNSettingsViewController class] image:[MiniUIImage imageNamed:@"more"] highlightedImage:[MiniUIImage imageNamed:@"more_hover"] title:@"更多"],
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

+ (MSMainTabViewController*)sharedInstance
{
    return tabController;
}

@end
