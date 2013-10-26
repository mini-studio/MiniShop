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
#import "MSPotentialViewController.h"
#import "MRLoginViewController.h"
#import "MSShopGalleryViewController.h"
#import "KeychainItemWrapper.h"
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
@property (nonatomic,strong)MiniUIButton *ringButton;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveVersion:) name:MN_NOTI_RECEIVE_VERSION object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self setNaviButtons];
}

- (void)setNaviButtons
{
    MiniUIButton *button  = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"button_push_message_open"] highlightedImage:nil];
    button.width = 40;
    self.ringButton = button;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(switchPushMessage:) forControlEvents:UIControlEventTouchUpInside];
    if ( self.navigationController.topViewController == self ) {
        button  = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"button_push_message_open"] highlightedImage:nil];
        button.width = 40;
        [self setNaviRightButtonImage:@"potential_n" highlighted:@"potential_h" target:self action:@selector(actionRightButtonTap:)];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
//    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number" accessGroup:nil];
//    NSString *udid = (NSString*)[keychainWrapper objectForKey:(__bridge id)kSecValueData];
//    if ( udid.length == 0 ) {
//        //[keychainWrapper setObject:@"A98NUYERNV09" forKey:(__bridge id)kSecValueData];
//    }
//    else {
//      
//       //udid = (NSString*)[keychainWrapper objectForKey:(__bridge id)kSecValueData];
//    }
    self.navigationItem.title = @"我关注的店";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dismissWating];
    [self checkImportTaobaoView];
    [self reviseRingButton:self.ringButton];
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
            __PSELF__;
            [button setTouchupHandler:^(MiniUIButton *button) {
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"showImportTaobaoView"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[pSelf.view viewWithTag:KIMPORT_VIEW_TAG] removeFromSuperview];
                 pSelf.tableView.hidden = NO;
                [pSelf actionForImportFav];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo *data = [ds objectAtIndex:section];
    if ( [data isKindOfClass:[MSPicNotiGroupInfo class]] ) {
        return 0;
    }
    else {
        if ( ds.count > section-1  ) {
            data = [ds objectAtIndex:section+1];
            if ( [data isMemberOfClass:[MSPicNotiGroupInfo class]] ) {
                return 6;
            }
        }
        return 0;
    }

}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo *data = [ds objectAtIndex:section];
    if ( [data isMemberOfClass:[MSPicNotiGroupInfo class]] ) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    else{
        if ( [data isMemberOfClass:[MSNotiGroupInfo class]] ) {
             return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        }
        else {
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 6)];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo *data = [ds objectAtIndex:section];
    if ( [data isMemberOfClass:[MSPicNotiGroupInfo class]] ) {
        return 30;
    }
    else {
        if ( [data isMemberOfClass:[MSNotiGroupInfo class]] ) {
            return 0;
        }
        else {
            return 0;
        }
    }
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo *data = [ds objectAtIndex:section];
    if ( [data isKindOfClass:[MSPicNotiGroupInfo class]] ) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_icon"]];
        imageView.frame = CGRectMake(10, 3, 24, 24);
        [view addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, tableView.width-60, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = data.name;
        [view addSubview:label];
        view.backgroundColor = [UIColor colorWithRGBA:0x33333344];
        MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        button.frame = view.bounds;
        [view addSubview:button];
        button.userInfo = data;
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_arrow"]];
        imageView.frame = CGRectMake(view.width - 30, 5, 20, 20);
        [view addSubview:imageView];
        [button addTarget:self action:@selector(actionToGalleryViewController:) forControlEvents:UIControlEventTouchUpInside];
        return view;
    }
    else{
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 6)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    return [MSNotiTableCell heightForItem:[ds objectAtIndex:indexPath.section] width:tableView.width];
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
    cell.controller = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *ds = [self dataSourceForType:self.segment.selectedSegmentIndex];
    MSNotiItemInfo * data = [ds objectAtIndex:indexPath.section];
    if ( [MSStoreNewsSubTypeReg isEqualToString:data.subtype] ) {
        if ( WHO == nil ) {
            MRLoginViewController *controller = [[MRLoginViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if ( [MSStoreNewsTypeTopic isEqualToString:data.type] )
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
        if ( [data isMemberOfClass:[MSNotiGroupInfo class]] ) {
            [self viewShopGallery:data];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if ( [MSStoreNewsTypeStorePromotion isEqualToString:data.type] ) //店铺活动
    {
        NSString* uri = [NSString stringWithFormat:@"http://%@?type=activity_shop&activity_id=%lld", StoreGoUrl, data.mid];
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:uri title:@"店铺活动" toolbar:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ( [MSStoreNewsTypeURL isEqualToString:data.type] )
    {
        if ( [MSStoreNewsSubTypeSubLogin isEqualToString:data.subtype] ) {
            __PSELF__;
            //[self userAuth:^{
                [MobClick event:MOB_MSG_URL_CLICK];
                MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:data.url title:[data name] toolbar:YES];
                [pSelf.navigationController pushViewController:controller animated:YES];
            //}];
        }
        else {
            [MobClick event:MOB_MSG_URL_CLICK];
            MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:data.url title:[data name] toolbar:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
       
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
    //self.segment.userInteractionEnabled = NO;
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
    [self showWating:nil];
    [[ClientAgent sharedInstance] loadNews:page userInfo:[NSNumber numberWithInt:0]
                                     block:^(NSError *error, MSNotify* data, id userInfo, BOOL cache) {
         
         if ( [userInfo intValue] == pSelf.segment.selectedSegmentIndex )
         {
             if ( error == nil )
             {
                 if ( data != nil )
                 {
                     if ( pSelf.mark )
                     {
                         for ( MSPicNotiGroupInfo *info in data.items_info )
                         {
                             info.isNews = YES;
                         }
                     }
                     [pSelf receiveData:data page:page type:type];
                 }
                 double delayInSeconds = 2.0;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     [pSelf dismissWating];
                 });
             }
             else
             {
                 [pSelf dismissWating];
                 [pSelf stopLoad:page];
                 
                 [pSelf showErrorMessage:error];
             }
         }
         else {
            [pSelf dismissWating];
         }
     }];

}

- (void)loadTopics:(int)page
{
    int type = 1;
    __PSELF__;
    [[ClientAgent sharedInstance] loadTopic:@"eyJ0eXBlIjoiZ3VhbmdfaW1hZ2UifQ==" page:page maxid:0 userInfo:nil block:^(NSError *error, MSNotify* data, id userInfo, BOOL cache) {
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
    for ( MSPicNotiGroupInfo *info in noti.items_info )
    {
        NSString *mid = [NSString stringWithFormat:@"%lld",info.mid];
        if ( [itemMap valueForKey:mid] == nil )
        {
            [ds addObject:info];
            [itemMap setValue:info forKey:mid];
        }
    }
    if ( itemMap.count == 0 && type ==0 && WHO != nil )
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

- (void)didReceiveVersion:(NSNotification *)noti
{
    [self reviseRingButton:self.ringButton];
}


- (void)actionForImportFav
{
    [MobClick event:MOB_IMPORT_FAV];
    if ( self.importing ) return;
    self.importing  = YES;
    __PSELF__;
    //[self userAuthWithString:LOGIN_IMPORT_FAV_PROMPT block:^{
        [pSelf showWating:nil];
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
    //}];
    
}

- (void)reviseRingButton:(MiniUIButton*)button
{
    if ( [@"0" isEqualToString:[MSSystem sharedInstance].version.push_sound] ) {
        [button setImage:[UIImage imageNamed:@"button_push_message_off"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"button_push_message_off_p"] forState:UIControlStateHighlighted];
    }
    else {
        [button setImage:[UIImage imageNamed:@"button_push_message_open"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"button_push_message_open_p"] forState:UIControlStateHighlighted];
 
    }
}

- (void)switchPushMessage:(MiniUIButton*)button
{
    __PSELF__;
    //[self userAuth:^{
        if ( [MSSystem sharedInstance].version.push_sound.intValue == 1 ) {
            [[ClientAgent sharedInstance] setpushsound:0 block:^(NSError *error, id data, id userInfo, BOOL cache) {
                if ( error == nil ) {
                    [MSSystem sharedInstance].version.push_sound = @"0";
                    [pSelf reviseRingButton:button];
                    [pSelf showMessageInfo:@"消息声音已关闭" delay:1];
                }
                else {
                    [pSelf showErrorMessage:error];
                }
            }];
        }
        else {
            [[ClientAgent sharedInstance] setpushsound:1 block:^(NSError *error, id data, id userInfo, BOOL cache) {
                if ( error == nil ) {
                    [MSSystem sharedInstance].version.push_sound = @"1";
                    [pSelf reviseRingButton:button];
                    [pSelf showMessageInfo:@"消息声音已开启" delay:1];
                }
                else {
                    [pSelf showErrorMessage:error];
                }
            }];
        }

    //}];
}

- (void)actionRightButtonTap:(UIButton *)button
{
    //[self userAuth:^{
        MSPotentialViewController *controller = [[MSPotentialViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    //}];
}

- (void)viewShopGallery:(MSNotiItemInfo*)itemInfo
{
    MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
    controller.notiInfo = itemInfo;
    controller.autoLayout = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionToGalleryViewController:(MiniUIButton*)button
{
    [self viewShopGallery:button.userInfo];
}


@end
