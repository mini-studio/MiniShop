//
//  MSNMyStoreViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-11-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNMyStoreViewController.h"
#import "MSNaviMenuView.h"
#import "MSTransformButton.h"
#import "MSNCate.h"

@interface MSNMyStoreViewController ()
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
    self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(self.topTitleView.width, 0, 50, self.naviTitleView.height)];
    [self.naviTitleView addSubview:self.transformButton];
    self.transformButton.items = @[@"新品",@"销量",@"折扣",@"降价"];
    UIImage *image = [UIImage imageNamed:@"icon_search"];
    MiniUIButton *searchButton= [MiniUIButton buttonWithImage:image highlightedImage:nil];
    CGFloat centerX = self.transformButton.right + (self.naviTitleView.width-self.transformButton.right)/2;
    searchButton.center = CGPointMake(centerX, self.transformButton.height/2);
    [self.naviTitleView addSubview:searchButton];
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
                MyStoreContentViewController *controller = [[MyStoreContentViewController alloc] init];
                controller.tagid = tag.tag_id;
                [pSelf.subControllers addObject:controller];
                [pSelf addChildViewController:controller];
                controller.view.frame = CGRectMake(index*pSelf.containerView.width, 0, pSelf.containerView.width, pSelf.containerView.height);
                [pSelf.containerView addSubview:controller.view];
            }
            pSelf.containerView.contentSize = CGSizeMake(count*pSelf.containerView.width, 0);
            [pSelf.topTitleView setNeedsLayout];
            pSelf.topTitleView.selectedIndex = 0;
            [(MyStoreContentViewController*)[pSelf.subControllers objectAtIndex:0] refreshData];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

@end

/****************************************************************************/
#include "MSNGoodsList.h"

#import "MSNGoodsTableCell.h"
/****************************************************************************/

@interface MyStoreContentViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)MSNGoodsList *dataSource;
@property (nonatomic)NSInteger page;

- (NSArray*)allGoodItems;
@end

@implementation MyStoreContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _page = 1;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    [self setNaviTitleViewShow:NO];
    [self createTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createTableView
{
    self.tableView = [self createEGOTableView];
    [self.contentView addSubview:self.tableView];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf loadData:1];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ds = (NSArray*)[self.dataSource dataAtIndex:(unsigned)indexPath.row];
    return [MSNGoodsTableCell heightForItems:ds width:tableView.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSNGoodsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSNGoodsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSArray *ds = [self.dataSource dataAtIndex:indexPath.row];
    if ( indexPath.section < ds.count )
    {
        cell.items = ds;
        [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor colorWithWhite:1.0f alpha:0.8f] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xCCCCCCAA]  sectionRowNumbers:1];   
    }
    cell.controller = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void)refreshData
{
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [self.tableView triggerRefresh];
}

- (void)selectedAsChild
{
    if ( self.dataSource.info.count == 0 ) {
        [self refreshData];
    }
}

- (void)loadMore
{
    [self loadData:(_page+1) delay:0.50f];
}

- (void)loadData:(int)page
{
    [self loadData:page delay:0.10];
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

- (void)receiveData:(MSNGoodsList*)data page:(int)page
{
    if ( page == 1 )
    {
        [self.tableView refreshDone];
         self.dataSource = data;
    }
    else {
        [self.dataSource append:data];
    }
    _page = page;
    [self.dataSource group];
    [self setMoreDataAction:(data.next_page==1) tableView:self.tableView];
    [self.tableView reloadData];
    LOG_DEBUG(@"%@",[data description]);
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    [self refreshData];
}

- (NSArray*)allGoodItems
{
    return [self.dataSource allSortedItems];
}


@end
