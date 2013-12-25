//
//  EspecialIndexViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "EspecialIndexViewController.h"

#import "MSNGoodsList.h"
#import "MSNGoodsTableCell.h"

@interface EspecialIndexViewController ()

@end

@implementation EspecialIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (MSNaviMenuView*)createNaviMenuAndSubControllers
{
    MSNaviMenuView *topTitleView = [[MSNaviMenuView alloc] initWithFrame:CGRectMake(0, 0,self.naviTitleView.width,self.naviTitleView.height)];
    self.topTitleView = topTitleView;
    topTitleView.backgroundColor = [UIColor redColor];
    __PSELF__;
    [[ClientAgent sharedInstance] specialcate:^(NSError *error, NSArray *data, id userInfo, BOOL cache) {
        if ( data != nil ) {
            for (int index = 0; index < data.count; index++) {
                MSNSpecialcate *cate = [data objectAtIndex:index];
                [pSelf.topTitleView addMenuTitle:cate.name userInfo:[NSString stringWithFormat:@"%d",index]];
                EspecialContentViewController *controller = [[EspecialContentViewController alloc] init];
                controller.cate = cate;
                [pSelf.subControllers addObject:controller];
                [pSelf addChildViewController:controller];
                controller.view.frame = CGRectMake(index*pSelf.containerView.width, 0, pSelf.containerView.width, pSelf.containerView.height);
                [pSelf.containerView addSubview:controller.view];
            }
            pSelf.containerView.contentSize = CGSizeMake(data.count*pSelf.containerView.width, 0);
            [pSelf.topTitleView setNeedsLayout];
            pSelf.topTitleView.selectedIndex = 0;
        }
    }];
    return topTitleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end


@interface EspecialContentViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)MSNGoodsList *dataSource;
@property (nonatomic)NSInteger page;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation EspecialContentViewController
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
    CGRect frame = self.view.bounds;
    self.tableView = [[EGOUITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    __weak typeof (self) itSelf = self;
    [self.tableView setPullToRefreshAction:^{
        [itSelf loadData:1];
    }];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self setPullToRefreshViewStyle:self.tableView.pullToRefreshView];
    [self.contentView addSubview:self.tableView];
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
        [[ClientAgent sharedInstance] specialgoods:self.cate.mid page:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if (error == nil) {
                [pSelf receiveData:data page:page];
            }
        }];
    });
}

- (void)setMoreDataAction
{
    if ( self.dataSource.next_page == 1 )
    {
        if (((EGOUITableView*)self.tableView).moreDataAction == nil)
        {
            if ( self.tableView.moreDataCell == nil )
            {
                self.tableView.moreDataCell = [[MSUIMoreDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"__More_Data_Cell"];
            }
            __PSELF__;
            [self.tableView setMoreDataAction:^{
                [pSelf loadMore];
            } keepCellWhenNoData:NO loadSection:NO];
            
        }
    }
    else
    {
        [self.tableView setMoreDataAction:nil keepCellWhenNoData:NO loadSection:NO];
    }
}

- (void)receiveData:(id)data page:(int)page
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
    [self setMoreDataAction];
    [self.tableView reloadData];
    LOG_DEBUG(@"%@",[data description]);
}


@end