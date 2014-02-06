//
//  MSNMyStoreViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNMyStoreViewController.h"
#import "MSNSearchGoodsViewController.h"
#import "MSNaviMenuView.h"
#import "MSTransformButton.h"
#import "MSNCate.h"
#import "MSNUISearchBar.h"

@interface MSNMyStoreViewController ()<MSTransformButtonDelegate>
@property (nonatomic,strong)MSTransformButton *transformButton;
@end

@implementation MSNMyStoreViewController

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
    self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(self.topTitleView.right+10, 0, 50, self.naviTitleView.height)];
    [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_white"] himage:[UIImage imageNamed:@"arrow_white"]];
    self.transformButton.backgroundColor = NAVI_BG_COLOR;
    [self.naviTitleView addSubview:self.transformButton];
    self.transformButton.items = @[@"新品",@"销量",@"折扣",@"降价"];
    self.transformButton.values = @[@"time",@"sale",@"off",@"off_time"];
    self.transformButton.delegate = self;
    self.transformButton.hidden = YES;
    UIImage *image = [UIImage imageNamed:@"icon_search"];
    MiniUIButton *searchButton= [MiniUIButton buttonWithImage:image highlightedImage:nil];
    CGFloat centerX = self.transformButton.right + (self.naviTitleView.width-self.transformButton.right)/2;
    searchButton.center = CGPointMake(centerX, self.transformButton.height/2);
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
                MSNMyStoreContentViewController *controller = [[MSNMyStoreContentViewController alloc] init];
                controller.tagid = tag.tag_id;
                [pSelf.subControllers addObject:controller];
                [pSelf addChildViewController:controller];
                controller.view.frame = CGRectMake(index*pSelf.containerView.width, 0, pSelf.containerView.width, pSelf.containerView.height);
                [pSelf.containerView addSubview:controller.view];
            }
            pSelf.containerView.contentSize = CGSizeMake(count*pSelf.containerView.width, 0);
            [pSelf.topTitleView setNeedsLayout];
            pSelf.topTitleView.selectedIndex = 0;
            [(MSNMyStoreContentViewController*)[pSelf.subControllers objectAtIndex:0] refreshData];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)actionJumpSearch:(MiniUIButton *)button
{
    MSNSearchGoodsViewController *controller = [[MSNSearchGoodsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)transformButtonValueChanged:(MSTransformButton*)button
{
    for (MSNMyStoreContentViewController *controller in self.subControllers ) {
        controller.orderby = button.selectedValue;
    }
}

@end

/****************************************************************************/
#import "MSNGoodsList.h"

#import "MSNGoodsTableCell.h"
/****************************************************************************/

@interface MSNMyStoreContentViewController()
@property (nonatomic) BOOL needReloadWhenDisplay;
@end

@implementation MSNMyStoreContentViewController
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
    MSNMyStoreViewController *parentController = (MSNMyStoreViewController *)[self parentViewController];
    if (parentController.currentController==self) {
       [self loadData:1 delay:0];
    }
    else {
        _needReloadWhenDisplay = YES;
    }
    
}

@end
