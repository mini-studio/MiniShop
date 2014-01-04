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

@interface MSNMyStoreViewController ()<MSNSearchViewDelegate>
@property (nonatomic,strong)MSTransformButton *transformButton;
@property (nonatomic,strong)MSNSearchView *searchView;
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
    self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(self.topTitleView.width, 0, 50, self.naviTitleView.height)];
    [self.naviTitleView addSubview:self.transformButton];
    self.transformButton.items = @[@"新品",@"销量",@"折扣",@"降价"];
    UIImage *image = [UIImage imageNamed:@"icon_search"];
    MiniUIButton *searchButton= [MiniUIButton buttonWithImage:image highlightedImage:nil];
    CGFloat centerX = self.transformButton.right + (self.naviTitleView.width-self.transformButton.right)/2;
    searchButton.center = CGPointMake(centerX, self.transformButton.height/2);
    [self.naviTitleView addSubview:searchButton];
    [searchButton addTarget:self action:@selector(actionShowSearchBar:) forControlEvents:UIControlEventTouchUpInside];
    self.searchView = [[MSNSearchView alloc] initWithFrame:CGRectMake(0, -self.naviTitleView.height, self.naviTitleView.width, self.naviTitleView.height)];
    self.searchView.delegate = self;
    self.searchView.scopeString = @[@"我的商城",@"整个好店汇"];
    [self.naviTitleView addSubview:self.searchView];
}

- (MSNaviMenuView*)createNaviMenuAndSubControllers
{
    MSNaviMenuView *topTitleView = [[MSNaviMenuView alloc] initWithFrame:CGRectMake(0, 0,self.naviTitleView.width-100,44)];
    topTitleView.backgroundColor = [UIColor redColor];
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

- (void)actionShowSearchBar:(MiniUIButton*)button
{
    [self.searchView show];
}

- (void)searchViewSearchButtonClicked:(MSNSearchView *)searchBar
{
    NSString *key = searchBar.text;
    if (key.length > 0) {
        MSNSearchGoodsViewController *controller = [[MSNSearchGoodsViewController alloc] init];
        controller.key = key;
        controller.scopeIndex = searchBar.scopeIndex;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end

/****************************************************************************/
#import "MSNGoodsList.h"

#import "MSNGoodsTableCell.h"
/****************************************************************************/

@interface MSNMyStoreContentViewController()
@end

@implementation MSNMyStoreContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)selectedAsChild
{
    if ( self.dataSource.info.count == 0 ) {
        [self refreshData];
    }
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
        [[ClientAgent sharedInstance] favshoplist:pSelf.tagid sort:SORT_TIME page:page block:^(NSError *error, MSNGoodsList *data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if (error == nil) {
                [pSelf receiveData:data page:page];
            }
        }];
    });
}

@end
