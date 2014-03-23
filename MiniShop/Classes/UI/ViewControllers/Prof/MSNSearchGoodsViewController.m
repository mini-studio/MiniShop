//
//  MSNSearchGoodsViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <sys/ucred.h>
#import "MSNSearchGoodsViewController.h"
#import "MSNUISearchBar.h"
#import "MSNTransformButton.h"
#import "UIColor+Mini.h"
#import "RTLabel.h"
#import "MSNHistroyView.h"

#define SEARCH_IN_MY_SHOP @"1"
#define SEARCH_IN_ALL_SHOP @"0"

@interface MSNSearchGoodsViewHeaderView : UIView
@property (nonatomic, strong)RTLabel *titleLabel;
@property (nonatomic, strong)MSNTransformButton *orderByButton;
@end

@implementation MSNSearchGoodsViewHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[RTLabel alloc] initWithFrame:CGRectMake(15, (self.height-16)/2, self.width*2/3-30, 16)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.orderByButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(self.titleLabel.right + 30, 0, self.width/3-60, self.height)];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.titleLabel.right, 0, 1, self.height)];
        separator.backgroundColor = [UIColor colorWithRGBA:0xd14c60ff];
        [self addSubview:self.titleLabel];
        [self addSubview:self.orderByButton];
        [self addSubview:separator];
        
        MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"order"] highlightedImage:[UIImage imageNamed:@"order_hover"]];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        button.frame = CGRectMake(_orderByButton.right, 0, 28, 28);
        [self addSubview:button];
        [button setTouchupHandler:^(MiniUIButton *button) {
            _orderByButton.selectedIndex = _orderByButton.selectedIndex+1;
        }];

    }
    return self;
}

- (void)setResultNumber:(int)number key:(NSString*)key
{
    [_titleLabel setText:[NSString stringWithFormat:@"<font color='#414345'>共有</font><font color='#d14c60'>%d</font>个宝贝",number]];
}

@end

@interface MSNSearchGoodsViewController ()<UITextFieldDelegate,MSTransformButtonDelegate,MSNUISearchBarDelegate>
@property (nonatomic,strong)MSNUISearchBar *searchBar;
@property (nonatomic,strong)MSNTransformButton *transformButton;
@property (nonatomic,strong)MiniUIButton *cancelButton;
@property (nonatomic,strong)MSNHistroyView *historyView;
@property (nonatomic,strong)MSNSearchGoodsViewHeaderView *titleSectionView;

@property (nonatomic, strong)UIView *emptyViewForMyShop;
@property (nonatomic, strong)UIView *emptyViewForAllShop;

@property (nonatomic, copy)NSString *searchKey;
@end

@implementation MSNSearchGoodsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.showNaviView = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect frame = CGRectMake(80, 0, self.naviTitleView.width-120, 44);
    self.searchBar = [[MSNUISearchBar  alloc] initWithFrame:frame];
    self.searchBar.inView = self.contentView;
    self.searchBar.delegate = self;
    self.searchBar.showCancelButtonWhenEdit = NO;
    self.searchBar.placeholder = @"搜商品";
    [self.naviTitleView addSubview:self.searchBar];

    [self.naviTitleView addSubview:self.searchBar];
    
    self.cancelButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(self.searchBar.right-4, 0, self.naviTitleView.width-self.searchBar.right,self.naviTitleView.height);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.naviTitleView addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(15, 0, 60, self.naviTitleView.height)];
    self.transformButton.items = @[@"在我的\n商城搜",@"在好店\n汇搜索"];
    self.transformButton.values = @[SEARCH_IN_MY_SHOP,SEARCH_IN_ALL_SHOP];
    self.transformButton.fontSize = 14;
    self.transformButton.delegate = self;
    [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_white"] himage:[UIImage imageNamed:@"arrow_white"]];
    [self.naviTitleView addSubview:self.transformButton];
    self.titleSectionView = [[MSNSearchGoodsViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 28)];
    self.titleSectionView .backgroundColor = [UIColor colorWithRGBA:0xfaf1f2ff];
    self.titleSectionView.orderByButton.items = @[@"新品",@"折扣",@"降价",@"销量"];
    self.titleSectionView.orderByButton.values = @[@"time",@"off",@"off_time",@"sale"];
    self.titleSectionView.orderByButton.fontColor = [UIColor colorWithRGBA:0xd14c60ff];
    self.titleSectionView.orderByButton.fontSize = 14;
    self.titleSectionView.orderByButton.delegate = self;
    
    self.historyView = [[MSNHistroyView alloc] initWithFrame:CGRectMake(0, -200, self.contentView.width, 200)];
    self.historyView.backgroundColor = [UIColor whiteColor];
    __PSELF__;
    self.historyView.onSelected = ^(NSString *word) {
        pSelf.searchBar.text = word;
        [pSelf loadData:1 delay:0];
    };
}

- (void)searchBarCancelButtonClicked:(MSNUISearchBar *)searchBar
{
    [self back];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSearchHistory];
}

- (void)loadSearchHistory
{
    [[ClientAgent sharedInstance] loadSearchHistory:^(NSError *error, NSArray* data, id userInfo, BOOL cache) {
        if (error==nil&&data.count>0) {
            self.historyView.historyItems = data;
            [self showHistoryView];
        }
    }];
}

- (void)showHistoryView
{
    [self.contentView addSubview:self.historyView];
    [self.historyView reload];
    [UIView animateWithDuration:0.25f animations:^{
        self.historyView.top = 0;
    }];
}

- (void)hiddenHistoryView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.historyView.bottom = 0;
    }];
}


- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.info.count==0) {
        return 0;
    }
    else {
        return 28;
    }
}

- (void)showEmptyView
{
    NSString *type = self.transformButton.selectedValue;
    UIView *view = [SEARCH_IN_MY_SHOP isEqualToString:type]?self.emptyViewForMyShop:self.emptyViewForAllShop;
    view.bottom = 0;
    [self.contentView addSubview:view];
    [UIView animateWithDuration:0.5 animations:^{
        view.top = 20;
    }];
}

- (void)hidesEmptyView:(void (^)())completion
{
    if (self.emptyViewForMyShop.superview!=nil || self.emptyViewForAllShop.superview!=nil){
        [UIView animateWithDuration:0.5 animations:^{
            if (self.emptyViewForMyShop.bottom!=0)
                self.emptyViewForMyShop.bottom = 0;
            if (self.emptyViewForAllShop.bottom!=0)
                self.emptyViewForAllShop.bottom = 0;
        }completion:^(BOOL finished){
            [self.emptyViewForMyShop removeFromSuperview];
            [self.emptyViewForAllShop removeFromSuperview];
            completion();
        }];
    }
    else {
        completion();
    }
}

- (UIView*)emptyViewForMyShop
{
    if (_emptyViewForMyShop==nil) {
        _emptyViewForMyShop = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.contentView.width-40, 130)];
        _emptyViewForMyShop.backgroundColor = [UIColor colorWithRGBA:0xffefd7ff];
        _emptyViewForMyShop.layer.cornerRadius = 4;
        _emptyViewForMyShop.layer.masksToBounds = YES;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, _emptyViewForMyShop.width-60, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRGBA:0xb08953FF];
        label.tag = 0x0111;

        [_emptyViewForMyShop addSubview:label];

        MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_s_button_normal"]
                highlightedBackGroundImage:[UIImage imageNamed:@"follow_s_button_selected"] title:@"搜索全站"];
        button.width = 120;
        button.center = CGPointMake(_emptyViewForMyShop.width/2, _emptyViewForMyShop.height-button.height);
        [_emptyViewForMyShop addSubview:button];

        __PSELF__;
        [button setTouchupHandler:^(MiniUIButton *button) {
            [pSelf hidesEmptyView:^{
                pSelf.transformButton.selectedIndex = 1;
            }];
        }];
    }
    UILabel *label = [_emptyViewForMyShop viewWithTag:0x0111];
    label.text = self.dataSource.search_shop_null_message.length==0?[NSString
            stringWithFormat:@"没有在您的商城里找到“%@”，试一试全站搜索？",self.searchKey]:self.dataSource.search_shop_null_message;
    return _emptyViewForMyShop;
}

- (UIView*)emptyViewForAllShop
{
    if (_emptyViewForAllShop==nil){
        _emptyViewForAllShop = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.contentView.width-40, 130)];
        _emptyViewForAllShop.backgroundColor = [UIColor colorWithRGBA:0xffefd7ff];
        _emptyViewForAllShop.layer.cornerRadius = 4;
        _emptyViewForAllShop.layer.masksToBounds = YES;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, _emptyViewForMyShop.width-60, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRGBA:0xb08953FF];
        label.tag = 0x0111;
        [_emptyViewForAllShop addSubview:label];

        MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"follow_s_button_normal"]
                                            highlightedBackGroundImage:[UIImage
                                                    imageNamed:@"follow_s_button_selected"] title:@"好"];
        button.width = 120;
        button.center = CGPointMake(_emptyViewForMyShop.width/2, _emptyViewForMyShop.height-button.height);
        [_emptyViewForAllShop addSubview:button];

        __PSELF__;
        [button setTouchupHandler:^(MiniUIButton *button) {
            [pSelf hidesEmptyView:^{}];
        }];
    }
    UILabel *label = [_emptyViewForAllShop viewWithTag:0x0111];
    label.text = self.dataSource.search_shop_null_message.length==0?[NSString stringWithFormat:@"没有找到“%@”相关信息",
                                                                                               self.searchKey]:self.dataSource.search_shop_null_message;
    return _emptyViewForAllShop;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.titleSectionView;
}

- (void)receiveData:(MSNGoodsList*)data page:(int)page
{
    [super receiveData:data page:page];
    if (data.info.count==0 && page==1) {
        [self showEmptyView];
    }
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    if (self.searchBar.text.length>0) {
        [self hiddenHistoryView];
        [self.searchBar endEditing:YES];
        __PSELF__;
        NSString *type = self.transformButton.selectedValue;
        self.searchKey = self.searchBar.text;
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] searchgoods:pSelf.searchBar.text type:type sort:[self.titleSectionView.orderByButton selectedValue] page:page block:^(NSError *error, MSNGoodsList* data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if (error==nil) {
                    [pSelf receiveData:data page:page];
                    [pSelf.titleSectionView setResultNumber:data.goods_num key:pSelf.searchBar.text];
                }
                else {
                    [pSelf showErrorMessage:error];
                }
            }];

        });
    }
    else {
        [self.tableView refreshDone];
    }
}

- (void)searchBarSearchButtonClicked:(MSNUISearchBar *)searchBar
{
     [self loadData:1 delay:0];
}

- (void)searchBarTextDidBeginEditing:(MSNUISearchBar *)searchBar
{
    [self loadSearchHistory];
}

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    [self hidesEmptyView:^{
        [self loadData:1 delay:0];
    }];

}

@end
