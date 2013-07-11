//
//  MSItemsViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSItemListViewController.h"
#import "MSNotify.h"
#import "SVPullToRefresh.h"
#import "UITableView+EGO.h"
#import "EGOUITableView.h"
#import "MSUIMoreDataCell.h"

@interface MSItemListViewController ()
@property (nonatomic) NSInteger page;
@end

@implementation MSItemListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self addRightRefreshButtonToTarget:self action:@selector(triggerRefresh)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBackButton];
    self.navigationItem.title = self.info.name;
    [self.tableView triggerRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSegmentControl
{
    
}

- (void)initData
{
   
}

- (void)triggerRefresh
{
    [self.tableView triggerRefresh];
}

- (void)refreshData
{
    [self loadLookData:1];
}

- (void)loadData:(int)page
{
    [self loadLookData:1];
}

- (void)loadMore
{
    [self loadLookData:self.page+1];
}

- (void)loadLookData:(NSInteger)page
{
    if ( [MSStoreNewsTypeSaunter isEqualToString:self.info.type] )
    {
        __PSELF__;
        [[ClientAgent sharedInstance] loadLookData:self.info.look_type page:page maxid:0 userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                [pSelf receiveData:data page:page];
            }
            else
            {
                [pSelf showErrorMessage:error];
            }
            
        }];
    }
    else if ( [MSStoreNewsTypeTopic isEqualToString:self.info.type] )
    {
        __PSELF__;
        [[ClientAgent sharedInstance] loadTopic:self.info.type page:page maxid:0 userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                [pSelf receiveData:data page:page];
            }
            else
            {
                [pSelf showErrorMessage:error];;
            }
        }];
    }
}

- (void)receiveData:(MSNotify *)noti page:(NSInteger)page
{
    self.page = page;
    if ( noti.items_info.count > 0 )
    {
        if ( ((EGOUITableView*)self.tableView).moreDataAction == nil )
        {
            __PSELF__;
            [self.tableView setMoreDataAction:^{
                [pSelf loadMore];
            }];
        }
    }
    else
    {
        [self.tableView setMoreDataAction:nil];
    }
    if ( page == 1 )
    {
        [self.dataSource removeAllObjects];
    }
    [self.dataSource addObjectsFromArray:noti.items_info];
    if ( page == 1 )
    {
        [self.tableView refreshDone];
        [self.tableView reloadData];
    }
    else
    {   
        if ( noti.items_info.count > 0 )
        {
            NSInteger from = self.dataSource.count - noti.items_info.count;
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:noti.items_info.count];
            for(NSInteger index = 0;index < noti.items_info.count; index++ )
            {
                [array addObject:[NSIndexPath indexPathForRow:0 inSection:from+index]];
            }
            [self.tableView reloadData];
        }
    }
}
@end
