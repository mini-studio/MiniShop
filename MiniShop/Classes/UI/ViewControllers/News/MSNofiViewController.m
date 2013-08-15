//
//  MSMessViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNofiViewController.h"
#import "UIColor+Mini.h"
#import "MSNotify.h"
#import "MSNotiItemInfo.h"
#import "MSNotiTableCell.h"
#import "UITableViewCell+GroupBackGround.h"
#import "MSItemListViewController.h"
#import "EGOUITableView.h"
#import "MSUIWebViewController.h"
#import "MSDetailViewController.h"
#import "NSString+Mini.h"
#import "NSString+URLEncoding.h"
#import "MSUIMoreDataCell.h"
#import "MiniUISegmentView.h"
#import "MSSystem.h"
#import "MSDefine.h"
#import "MSShopGroupListViewController.h"
#import <QuartzCore/QuartzCore.h>

#define KIMPORT_VIEW_TAG 0xAB0000

@interface MSNofiViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) int newsPage;
@property (nonatomic) int topicPage;
@property (nonatomic, strong) NSMutableDictionary *offsetDic;
@property (nonatomic) NSInteger lastSelectIndex;
@property (nonatomic) NSInteger currentSelectIndex;
@property (nonatomic, strong)NSMutableDictionary *dictionary;
@property (nonatomic) BOOL importing;
@property (nonatomic) NSMutableDictionary *itemDic;
@end

@implementation MSNofiViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.dataSource = [[NSMutableArray alloc] init];
        self.topicDataSource = [[NSMutableArray alloc] init];
        self.newsPage = self.topicPage = 1;
        self.offsetDic = [NSMutableDictionary dictionary];
        self.dictionary = [NSMutableDictionary dictionary];
        self.itemDic = [NSMutableDictionary dictionary];
        self.mark = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:MSNotificationReceiveRemote object:nil];
    }
    return self;
}

- (NSMutableArray *)dataSourceForType:(int)type
{
    if ( type == 0) return self.dataSource;
    else return self.topicDataSource;
}

- (NSMutableDictionary *)itemMapForType:(int)type
{
    NSMutableDictionary *dic = [self.itemDic valueForKey:[NSString stringWithFormat:@"%d",type]];
    if ( dic == nil )
    {
        dic = [NSMutableDictionary dictionary];
        [self.itemDic setValue:dic forKey:[NSString stringWithFormat:@"%d",type]];
    }
    return dic;
}

- (void)loadView
{
    [super loadView];
    [self addSegmentControl];
    [self createTableView];
    MiniUIButton *button  = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"button_push_message_open"] highlightedImage:nil];
    button.width = 40;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(switchPushMessage:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    self.navigationItem.title = @"上新";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dismissWating];
    [self checkImportTaobaoView];
}

- (void)checkImportTaobaoView
{
    id sv = [[NSUserDefaults standardUserDefaults] valueForKey:@"showImportTaobaoView"];
    if ( sv != nil )
    {
        UIView *v = [self.view viewWithTag:KIMPORT_VIEW_TAG];
        if ( v != nil )
        {
            [v removeFromSuperview];
        }
        self.tableView.hidden = NO;
    }
}

- (void)createImportTaobaoView
{
    id sv = [[NSUserDefaults standardUserDefaults] valueForKey:@"showImportTaobaoView"];
    if ( sv == nil )
    {
        if ( nil ==  [self.view viewWithTag:KIMPORT_VIEW_TAG] )
        {
            self.importing = NO;
            UIImageView *importTaobaoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"import_taobao"]];
            importTaobaoView.center = CGPointMake(self.view.width/2, importTaobaoView.height/2 + 20);
            importTaobaoView.userInteractionEnabled = YES;
            MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"button_h_normal"] highlightedBackGroundImage:[UIImage imageNamed:@"button_h_selected"] title:@"立即导入"];
            [button prefect];
            button.frame = CGRectMake((importTaobaoView.width-233)/2, importTaobaoView.height - 85, 233, 45);
            [importTaobaoView addSubview:button];
            importTaobaoView.tag = KIMPORT_VIEW_TAG;
            [self.view addSubview:importTaobaoView];
            self.tableView.hidden = YES;
            [button setTouchupHandler:^(MiniUIButton *button) {
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"showImportTaobaoView"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self actionForImportFav];
            }];
        }
    }
}

- (void)initData
{
    self.segment.selectedSegmentIndex = [self defaultDataType];
}

- (NSInteger)defaultDataType
{
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createTableView
{
    CGRect frame = self.view.bounds;
    frame = CGRectInset(frame, 5, 0);
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
    [self.view addSubview:self.tableView];
}

- (void)addSegmentControl
{    
    UIImage *deImage = [MiniUIImage imageNamed:@"transparent"];
    UIImage *hiImage = [MiniUIImage imageNamed:@"transparent"];
    MiniUISegmentView *segment = [[MiniUISegmentView alloc] initWithFrame:CGRectMake(0, (self.navigationController.navigationBar.height-30)/2, self.view.width-160, 30)];
    segment.layer.cornerRadius = 4;
    segment.layer.borderColor = [UIColor colorWithRGBA:0x8d061cFF].CGColor;
    segment.layer.borderWidth = 2.0f;
    segment.separatorColor = [UIColor colorWithRGBA:0x8d061c00];
    segment.backGroundImage = [UIImage imageNamed:@"segment_bg"];
    segment.slidderImage = [UIImage imageNamed:@"segment_btn_normal"];

    [segment setTarget:self selector:@selector(actionForLoadNews:)];
    [segment setItems:@[
     @"我的关注",self,@"",deImage,hiImage,
     @"随便看看",self,@"",deImage,hiImage
     ]];
    for (UIView *view in segment.subviews )
    {
        if ([view isKindOfClass:[MiniUIButton class]] )
        {
            [(MiniUIButton*)view setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [(MiniUIButton*)view setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        }
    }
    //self.navigationItem.titleView = segment;
    self.segment = segment;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self dataSourceForType:self.segment.selectedSegmentIndex].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 6)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell sizeToFit];
    return cell.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSNotiTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSNotiTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    if ( indexPath.section < ds.count )
    {
        [cell setItem:[ds objectAtIndex:indexPath.section]];
        [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor colorWithWhite:1.0f alpha:0.8f] highlightedBackgroundCorlor:[UIColor colorWithRGBA:0xCCCCCCAA]  sectionRowNumbers:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo * data = [ds objectAtIndex:indexPath.section];
    if ( [MSStoreNewsTypeTopic isEqualToString:data.type] )
    {
        [MobClick event:MOB_MSG_LOOK_CLICK];
        MSItemListViewController *controller = [[MSItemListViewController alloc] init];
        controller.info = data;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ( [MSStoreNewsTypeGoodsPromotion isEqualToString:data.type] || [MSStoreNewsTypePrevue isEqualToString:data.type] ||
             [MSStoreNewsTypeNewProduct isEqualToString:data.type])// 
    {
        [MobClick event:MOB_MSG_GOODS_CLICK];
        [data setRead:YES];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        MSDetailViewController *controller = [[MSDetailViewController alloc] init];
        controller.itemInfo = data;
        controller.from = @"list";
        controller.mtitle = [MSStoreNewsTypeGoodsPromotion isEqualToString:data.type]?@"店家活动":@"最新上新";
        controller.more = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ( [MSStoreNewsTypeStorePromotion isEqualToString:data.type] ) //店铺活动
    {
        NSString* uri = [NSString stringWithFormat:@"http://%@?type=activity_shop&activity_id=%lld", StoreGoUrl, data.mid];
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:uri title:@"店铺活动" toolbar:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ( [MSStoreNewsTypeURL isEqualToString:data.type] )
    {
        [MobClick event:MOB_MSG_URL_CLICK];
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:data.url title:[data name] toolbar:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)actionForloadSegTouchDown:(MiniUISegmentView*)sender
{
    int type = sender.selectedSegmentIndex;
    [self.offsetDic setValue:[NSValue valueWithCGPoint:self.tableView.contentOffset] forKey:[NSString stringWithFormat:@"%d",type]];
}

- (void)actionForLoadNews:(MiniUISegmentView*)sender
{
    int type = sender.selectedSegmentIndex;
    NSMutableArray *ds = [self dataSourceForType:sender.selectedSegmentIndex];
    if ( type==0) [MobClick event:MOB_NAV_FOLLOW_CLICK];
    else [MobClick event:MOB_NAV_TOPIC_CLICK];
    
    if ( ds.count == 0 )
    {
        self.lastSelectIndex = type;
        [self loadData:(type==0)?self.newsPage:self.topicPage];
    }
    else
    {
        self.lastSelectIndex = type;
        [self.tableView reloadData];
        NSValue *offset = [self.offsetDic valueForKey:[NSString stringWithFormat:@"%d",type]];
        if ( offset != nil )
        {
            self.tableView.contentOffset = [offset CGPointValue];
        }
        [self setMoreDataAction:sender.selectedSegmentIndex];
    }
}

- (void)refreshData
{
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [self.tableView triggerRefresh];
}


- (void)loadMore
{
    int type = self.segment.selectedSegmentIndex;
    int page = 0;
    if ( type == 0 ) page = self.newsPage + 1;
    else page = self.topicPage + 1;
    [self loadData:page delay:0.50f];
}

- (void)loadData:(int)page
{
    [self loadData:page delay:0.10];
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    self.segment.userInteractionEnabled = NO;
    [self showWating:nil];
    int type = self.segment.selectedSegmentIndex;
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ( type == 0 )
        {
            [self loadNews:page];
        }
        else
        {
            [self loadTopics:page];
        }
    });
}

- (void)loadNews:(int)page
{
    int type = 0;
    __weak typeof (self) pSelf = self;
    [[ClientAgent sharedInstance] loadNews:page userInfo:[NSNumber numberWithInt:0]
                                     block:^(NSError *error, MSNotify* data, id userInfo, BOOL cache) {
         [pSelf dismissWating];
         if ( [userInfo intValue] == pSelf.segment.selectedSegmentIndex )
         {
             if ( error == nil )
             {
                 if ( data != nil )
                 {
                     if ( pSelf.mark )
                     {
                         for ( MSNotiItemInfo *info in data.items_info )
                         {
                             info.isNews = YES;
                         }
                     }
                     [pSelf receiveData:data page:page type:type];
                 }
             }
             else
             {
                 [pSelf stopLoad:page];
                 [pSelf showErrorMessage:error];
             }
         }
     }];

}

- (void)loadTopics:(int)page
{
    int type = 1;
    __PSELF__;
    [[ClientAgent sharedInstance] loadTopic:@"eyJ0eXBlIjoiZ3VhbmcifQ==" page:page maxid:0 userInfo:nil block:^(NSError *error, MSNotify* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil )
        {
            [pSelf receiveData:data page:page type:type];
        }
        else
        {
            [pSelf stopLoad:page];
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)setMoreDataAction:(int)type
{
    MSNotify *noti = [self.dictionary valueForKey:[NSString stringWithFormat:@"%d",type]];
    if ( noti.next_page == 1 )
    {
        if (((EGOUITableView*)self.tableView).moreDataAction == nil)
        {
            if ( self.tableView.moreDataCell == nil || ![self.tableView.moreDataCell isKindOfClass:[MSUIMoreDataCell class]])
            {
                self.tableView.moreDataCell = [[MSUIMoreDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"__More_Data_Cell"];
               
            }
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
}

- (void)stopLoad:(int)page
{
    if ( page == 1 )
    {
        [self.tableView refreshDone];
    }
    [self.tableView reloadData];
}

- (void)receiveData:(MSNotify *)noti page:(int)page type:(int)type
{
    [self.dictionary setValue:noti forKey:[NSString stringWithFormat:@"%d",type]];
    [self setMoreDataAction:type];
    NSMutableArray *ds = [self dataSourceForType:type];
    if ( page == 1 )
    {
        [self.tableView refreshDone];
        [ds removeAllObjects];
        NSMutableDictionary *itemMap = [self itemMapForType:type];
        [itemMap removeAllObjects];
    }
    if ( noti.official.count == 0 && noti.topic.count == 0 && noti.items_info.count == 0 )
    {
        return;
    }
    if ( type == 0 )
    {
        self.newsPage = page;
    }
    else
    {
        self.topicPage = page;
    }
    [ds addObjectsFromArray:noti.official];
    [ds addObjectsFromArray:noti.topic];
    NSMutableDictionary *itemMap = [self itemMapForType:type];
    for ( MSNotiItemGroupInfo *info in noti.items_info )
    {
        NSString *mid = [NSString stringWithFormat:@"%lld",info.mid];
        if ( [itemMap valueForKey:mid] == nil )
        {
            [ds addObject:info];
            [itemMap setValue:info forKey:mid];
        }
    }
    if ( itemMap.count == 0 && type ==0 )
    {
        [self createImportTaobaoView];
    }
    [self.tableView reloadData];
    //self.segment.userInteractionEnabled = YES;
}

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    self.segment.selectedSegmentIndex = 0;
    [self refreshData];
}


- (void)actionForImportFav
{
    [MobClick event:MOB_IMPORT_FAV];
    if ( self.importing ) return;
    self.importing  = YES;
    [self showWating:nil];
    __weak typeof (self) pSelf = self;
    [[ClientAgent sharedInstance] importFav:self userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        pSelf.importing = NO;
        if ( error == nil )
        {
            LOG_DEBUG(@"%@",data);
            MSShopGroupListViewController *controller = [[MSShopGroupListViewController alloc] init];
            controller.type = EImportFav;
            controller.favData = data;
            [pSelf.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)switchPushMessage:(MiniUIButton*)button
{
    if ( [[MSSystem sharedInstance].version.push_sound isEqualToString:@"1"]) {
        [[ClientAgent sharedInstance] setpushsound:0 block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil ) {
                [MSSystem sharedInstance].version.push_sound = @"0";
                 [button setImage:[UIImage imageNamed:@"button_push_message_off"] forState:UIControlStateNormal];
            }
        }];
    }
    else {
        [[ClientAgent sharedInstance] setpushsound:1 block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil ) {
                [MSSystem sharedInstance].version.push_sound = @"1";
                [button setImage:[UIImage imageNamed:@"button_push_message_open"] forState:UIControlStateNormal]; 
            }
        }];
    }
}


@end
