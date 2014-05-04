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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTI_USER_LOGIN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTI_CONTENT_CHANGE object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

- (void)loadView
{
    [super loadView];
    self.naviTitleView.layer.masksToBounds = YES;
    self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(self.topTitleView.right+10, 0, 50, self.naviTitleView.height)];
    [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_white"] himage:[UIImage imageNamed:@"arrow_white"]];
    self.transformButton.backgroundColor = NAVI_BG_COLOR;
    [self.naviTitleView addSubview:self.transformButton];
    self.transformButton.items = @[@"新品",@"销量",@"降价"];
    self.transformButton.values = @[@"time",@"sale",@"off_time"];
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
    [self.subControllers removeAllObjects];
    [self.topTitleView clear];
    [self.containerView removeAllSubviews];
    [[ClientAgent sharedInstance] favshopcate:^(NSError *error, MSNCateList* data, id userInfo, BOOL cache) {
        if ( error==nil ) {
            pSelf.transformButton.hidden = NO;
            int count = data.info.count;
            for ( int index = 0; index < count; index++ ) {
                MSNCate *tag = [data.info objectAtIndex:index];
                [pSelf.topTitleView addMenuTitle:tag.tag_name userInfo:[NSString stringWithFormat:@"%d",index]];
                MSNStoreContentViewController *controller = [[MSNStoreContentViewController alloc] init];
                controller.tagId = tag.tag_id;
                [pSelf.subControllers addObject:controller];
                [pSelf addChildViewController:controller];
                controller.view.frame = CGRectMake(index*pSelf.containerView.width, 0, pSelf.containerView.width, pSelf.containerView.height);
                [pSelf.containerView addSubview:controller.view];
            }
            pSelf.containerView.contentSize = CGSizeMake(count*pSelf.containerView.width, 0);
            [pSelf.topTitleView setNeedsLayout];
            pSelf.topTitleView.selectedIndex = 0;
            //[(MSNStoreContentViewController*)[pSelf.subControllers objectAtIndex:0] refreshData];
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

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    for (MSNStoreContentViewController *controller in self.subControllers ) {
        controller.orderBy = button.selectedValue;
    }
}

- (void)reloadData
{
    [self loadData];
}

@end

/****************************************************************************/
/****************************************************************************/

@interface MSNStoreContentViewController()
@property (nonatomic) BOOL needReloadWhenDisplay;
@end

@implementation MSNStoreContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _orderBy = SORT_TIME;
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

- (void)setBackGroundImage:(NSString *)imageName
{
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    [self refreshData];
}

- (void)receiveData:(MSNGoodsList*)data page:(int)page
{
    if (page==1 && data.info.count==0) {
        if ( page == 1 ) {
            [self.tableView refreshDone];
        }
        [self showEmptyView];
        if ([self.orderBy isEqualToString:@"off_time"]) {
            [self showMessageInfo:@"没有降价的商品" delay:2];
        }
    }
    else {
        [self removeEmptyView];
        [super receiveData:data page:page];
    }
}

- (void)removeEmptyView
{
    UIView *view = [self.contentView viewWithTag:100];
    if (view!=nil) {
        [view removeFromSuperview];
    }
}

- (void)showEmptyView
{
    if (self.dataSource.info.count>0) {
        self.dataSource = nil;
        [self.tableView reloadData];
    }
    UIView *view = [self.contentView viewWithTag:100];
    if (view==nil) {
        UIImage *image = [MiniUIImage imagePreciseNamed:@"empty" ext:@"png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.userInteractionEnabled = YES;
        imageView.size = WINDOW.size;
        imageView.origin = CGPointMake(0, -66);
        [self.contentView addSubview:imageView];
        MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.contentView.bounds;
        [imageView addSubview:button];
        imageView.tag = 100;
        
        [button setTouchupHandler:^(MiniUIButton *button) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.right=0;
            } completion:^(BOOL finished) {
                //[imageView removeFromSuperview];
                MSMainTabViewController *controller = [MSMainTabViewController sharedInstance];
                controller.currentSelectedIndex = 2;
                imageView.left=0;
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
        [[ClientAgent sharedInstance] favshoplist:pSelf.tagId sort:self.orderBy page:page block:^(NSError *error, MSNGoodsList *data, id userInfo, BOOL cache) {
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


- (void)setOrderBy:(NSString *)orderBy
{
    _orderBy = orderBy;
    MSNStoreViewController *parentController = (MSNStoreViewController *)[self parentViewController];
    if (parentController.currentController==self) {
       [self showWating:nil];
       [self loadData:1 delay:0];
    }
    else {
        _needReloadWhenDisplay = YES;
    }
    
}

@end
