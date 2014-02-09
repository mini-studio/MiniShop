//
//  MSNStoreViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNStoreViewController.h"
#import "MSNSearchGoodsViewController.h"
#import "MSNaviMenuView.h"
#import "MSNTransformButton.h"
#import "MSNCate.h"
#import "MSNUISearchBar.h"
#import "MSMainTabViewController.h"

@interface MSNStoreViewController ()<MSTransformButtonDelegate>
@property (nonatomic,strong)MSNTransformButton *transformButton;
@end

@implementation MSNStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.naviTitleView.layer.masksToBounds = YES;
    self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(self.topTitleView.right+10, 0, 50, self.naviTitleView.height)];
    [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_white"] himage:[UIImage imageNamed:@"arrow_white"]];
    self.transformButton.backgroundColor = NAVI_BG_COLOR;
    [self.naviTitleView addSubview:self.transformButton];
    self.transformButton.items = @[@"新品",@"销量",@"折扣",@"降价"];
    self.transformButton.values = @[@"time",@"sale",@"off",@"off_time"];
    self.transformButton.delegate = self;
    self.transformButton.hidden = YES;
    UIImage *image = [UIImage imageNamed:@"icon_search"];
    MiniUIButton *searchButton= [MiniUIButton buttonWithImage:image highlightedImage:nil];
    searchButton.frame = CGRectMake(self.transformButton.right, 0, self.naviTitleView.width-self.transformButton.right, self.naviTitleView.height);
    [self.naviTitleView addSubview:searchButton];
    [searchButton addTarget:self action:@selector(actionJumpSearch:) forControlEvents:UIControlEventTouchUpInside];
}

- (MSNaviMenuView*)createNaviMenuAndSubControllers
{
    MSNaviMenuView *topTitleView = [[MSNaviMenuView alloc] initWithFrame:CGRectMake(15, 0,self.naviTitleView.width-125,44)];
    topTitleView.backgroundColor = NAVI_BG_COLOR;
    return topTitleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] favshopcate:^(NSError *error, MSNCateList* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error==nil ) {
            pSelf.transformButton.hidden = NO;
            int count = data.info.count;
            for ( int index = 0; index < count; index++ ) {
                MSNCate *tag = [data.info objectAtIndex:index];
                [pSelf.topTitleView addMenuTitle:tag.tag_name userInfo:[NSString stringWithFormat:@"%d",index]];
                MSNStoreContentViewController *controller = [[MSNStoreContentViewController alloc] init];
                controller.tagid = tag.tag_id;
                [pSelf.subControllers addObject:controller];
                [pSelf addChildViewController:controller];
                controller.view.frame = CGRectMake(index*pSelf.containerView.width, 0, pSelf.containerView.width, pSelf.containerView.height);
                [pSelf.containerView addSubview:controller.view];
            }
            pSelf.containerView.contentSize = CGSizeMake(count*pSelf.containerView.width, 0);
            [pSelf.topTitleView setNeedsLayout];
            pSelf.topTitleView.selectedIndex = 0;
            [(MSNStoreContentViewController*)[pSelf.subControllers objectAtIndex:0] refreshData];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)actionJumpSearch:(MiniUIButton *)button
{
//    MSMainTabViewController *controller = [MSMainTabViewController sharedInstance];
//    controller.currentSelectedIndex = 2;
    MSNSearchGoodsViewController *controller = [[MSNSearchGoodsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    for (MSNStoreContentViewController *controller in self.subControllers ) {
        controller.orderby = button.selectedValue;
    }
}

@end

/****************************************************************************/
#import "MSNGoodsList.h"

#import "MSNGoodsTableCell.h"
/****************************************************************************/

@interface MSNStoreContentViewController()
@property (nonatomic) BOOL needReloadWhenDisplay;
@end

@implementation MSNStoreContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _orderby = SORT_TIME;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:MSNotificationReceiveRemote object:nil];
    }
    return self;
}

- (void)setStatusBar
{
}

- (void)setBackGroudImage:(NSString *)imageName
{
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    [self refreshData];
}

- (void)receiveData:(MSNGoodsList*)data page:(int)page
{
    if (page==1) {
        [self showEmptyView];
    }
    else {
        [super receiveData:data page:page];
    }
}

- (void)showEmptyView
{
    UIView *view = [self.view.superview viewWithTag:100];
    if (view==nil) {
    UIView *view = [[UIView alloc] initWithFrame:self.contentView.bounds];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.width, WINDOW.size.height)];
    bgImageView.image = [UIImage imageNamed:@"background_image"];
    [view addSubview:bgImageView];
    bgImageView.centerY = view.height/2;
    CGFloat scale = (WINDOW.size.height/1136.0f);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80.0f*scale, view.width, 16)];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = @"现在，建一座自己的商城！";
    [view addSubview:label];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newpic"]];
    imageView.center = CGPointMake(view.width/2, imageView.height/2+label.bottom+26*scale);
    [view addSubview:imageView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom+20*scale, view.width, 90)];
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.text =@"想象一下，拥有一座属于您自己的商城\n里面都是你喜欢的品牌，信赖的卖家\n您可以在里面放心购物，自由血拼\n这是您自己的新光、万隆、春熙......\n期待吗？那就马上开始吧";
    [view addSubview:label];
    
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"bigbtn"] highlightedImage:nil];
    button.size = CGSizeMake(200 , button.height*(200.0f/button.width));
    button.center = CGPointMake(view.width/2,view.height-(WINDOW.size.height>480?46:22)-button.height/2);
    [view addSubview:button];
    
    [self.view.superview addSubview:view];
    view.tag = 100;
    
    [button setTouchupHandler:^(MiniUIButton *button) {
        [UIView animateWithDuration:0.5 animations:^{
            view.right=0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            MSMainTabViewController *controller = [MSMainTabViewController sharedInstance];
            controller.currentSelectedIndex = 2;
        }];

    }];
    }
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    __PSELF__;
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showWating:nil];
        [[ClientAgent sharedInstance] favshoplist:pSelf.tagid sort:self.orderby page:page block:^(NSError *error, MSNGoodsList *data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if (error == nil) {
                [pSelf receiveData:data page:page];
            }
        }];
    });
}

- (BOOL)needsRefreshData
{
    BOOL needs =  (self.dataSource.info.count == 0 || _needReloadWhenDisplay);
    _needReloadWhenDisplay = NO;
    return needs;
}


- (void)setOrderby:(NSString *)orderby
{
    _orderby = orderby;
    MSNStoreViewController *parentController = (MSNStoreViewController *)[self parentViewController];
    if (parentController.currentController==self) {
       [self loadData:1 delay:0];
    }
    else {
        _needReloadWhenDisplay = YES;
    }
    
}

@end