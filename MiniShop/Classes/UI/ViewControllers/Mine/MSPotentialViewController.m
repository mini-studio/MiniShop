//
//  MSPotentialViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSPotentialViewController.h"
#import "MSDetailViewController.h"
#import "UILabel+Mini.h"
#import "UIColor+Mini.h"
#import "MSPotentialInfo.h"
#import "MSUIPotentialCell.h"
#import "UITableView+EGO.h"
#import "EGOUITableView.h"

@interface MSPotentialViewController ()<UITableViewDataSource,UITabBarDelegate>
@property (nonatomic,strong) EGOUITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) MiniUIButton *label;
@property (nonatomic) int page;
@property (nonatomic) BOOL nextPage;
@end

@implementation MSPotentialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.tableView = (EGOUITableView*)[self createPlainTableView];
    [self.contentView addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBackButton];
	self.naviTitleView.title = @"纠结清单";
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    UIImage *image = [UIImage imageNamed:@"kink_title_bar"];
    self.label = [MiniUIButton buttonWithBackGroundImage:image highlightedBackGroundImage:image title:@"我曾仔细或反复看过的商品:"];
    self.label.frame = CGRectMake(0, 10, self.label.width+30, 38);
    self.label.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.label.titleLabel.textColor = [UIColor colorWithRGBA:0xc56349ff];
    [view addSubview:self.label];
    self.label.hidden = YES;
    self.label.userInteractionEnabled = NO;
    self.tableView.tableHeaderView = view;
    [self loadData:1];
     [MobClick event:MOB_OPEN_KINK_LIST];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count > 0 ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MSUIPotentialCell heightForShopInfo:self.dataSource];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSUIPotentialCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSUIPotentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.dataSource = self.dataSource;
    __weak typeof (self) pSelf = self;
    [cell setHandleTouchItem:^(MSGoodsItem *item) {
        [pSelf handleTouchItem:item];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadMore
{
    [self loadData:(self.page+1)];
}

- (void)loadData:(int)page
{
    [self showWating:nil];
    __weak typeof (self) pSelf = self;
    [[ClientAgent sharedInstance] kinkList:nil page:page block:^(NSError *error, MSPotentialInfo* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            if ( [data isKindOfClass:[MSPotentialInfo class]] )
            {
                if ( page == 1 )
                {
                    [pSelf.dataSource removeAllObjects];
                }
                [pSelf.dataSource addObjectsFromArray:data.kink_goods_info];
                pSelf.page = page;
                pSelf.nextPage = data.next_page;
                if ( pSelf.nextPage == 1 )
                {
                    [pSelf.tableView setMoreDataAction:^{
                        [pSelf loadMore];
                    } keepCellWhenNoData:NO loadSection:NO];
                }
                else
                {
                    [pSelf.tableView setMoreDataAction:nil keepCellWhenNoData:NO loadSection:NO];
                }
            }
            if ( pSelf.dataSource.count == 0 )
            {
                 pSelf.label.titleLabel.text = @"暂未发现你有纠结啥…";
            }
            else
            {
                 pSelf.label.titleLabel.text = @"我曾仔细或反复看过的商品:";
            }
            pSelf.label.hidden = NO;
            [pSelf.tableView reloadData];
        }
    }];
}


- (void)handleTouchItem:(MSGoodsItem *)item
{
    MSGoodsList *goodsList = [[MSGoodsList alloc] init];
    goodsList.body_info = self.dataSource;
    NSInteger index = [self.dataSource indexOfObject:item];
    MSDetailViewController *controller = [[MSDetailViewController alloc] init];
    controller.defaultIndex = index;
    controller.mtitle = @"";
    controller.more = NO;
    controller.goods = goodsList;
    controller.from = @"kink";
    [self.navigationController pushViewController:controller animated:YES];
}

@end
