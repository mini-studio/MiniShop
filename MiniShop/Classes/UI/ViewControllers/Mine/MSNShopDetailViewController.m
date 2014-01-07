//
//  MSNShopDetailViewController.m
//  MiniShop
//  店铺详情页
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopDetailViewController.h"
#import "MSNShopInfoView.h"
#import "MSNUISearchBar.h"
#import "MSTransformButton.h"
#import "UIColor+Mini.h"

@interface MSNShopMessageView : UIView
@property (nonatomic,strong)UILabel *numberLabel;
@property (nonatomic,strong)MSTransformButton *transformButton;
@property (nonatomic,strong)MiniUIButton *searchButton;
@end

@implementation MSNShopMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = NAVI_BG_COLOR;
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, self.height)];
        [self addSubview:self.numberLabel];
        
        self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(210, 0, 50, self.height)];
        self.transformButton.backgroundColor = NAVI_BG_COLOR;
        self.transformButton.items = @[@"新品",@"销量",@"折扣",@"降价"];
        [self addSubview:self.transformButton];
        
        UIImage *image = [UIImage imageNamed:@"icon_search"];
        self.searchButton= [MiniUIButton buttonWithImage:image highlightedImage:nil];
        self.searchButton.center = CGPointMake(self.width-20 - self.searchButton.width/2 , self.height/2);
        [self addSubview:self.searchButton];
    }
    return self;
}

@end

@interface MSNShopDetailViewController () <MSNSearchViewDelegate>
@property (nonatomic,strong)MSNShopInfoView *shopInfoView;
@property (nonatomic,strong)MSNSearchView *searchView;
@property (nonatomic,strong)MSNShopMessageView *messageView;
@end

@implementation MSNShopDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.showNaviView = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	[self setNaviBackButton];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 120)];
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 80)];
    [view addSubview:self.shopInfoView];
    
    CGRect rect = CGRectMake(0, self.shopInfoView.bottom, self.naviTitleView.width, 40);
    UIView *subView = [[UIView alloc] initWithFrame:rect];
    [view addSubview:subView];
    subView.layer.masksToBounds = YES;
    
    self.messageView = [[MSNShopMessageView alloc] initWithFrame:subView.bounds];
    [subView addSubview:self.messageView];
    [self.messageView.searchButton addTarget:self action:@selector(actionShowSearchView) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchView = [[MSNSearchView alloc] initWithFrame:CGRectMake(0, -40, rect.size.width, rect.size.height)];
    self.searchView.floatting = NO;
    self.searchView.delegate = self;
    [self.searchView setScopeString:@[@"店内"] defaultIndex:0];
    [subView addSubview:self.searchView];
    
    self.tableView.tableHeaderView = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.naviTitleView setTitle:self.shopInfo.shop_title];
    [self.shopInfoView setShopInfo:self.shopInfo];
    [self loadData:1 delay:0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    [[ClientAgent sharedInstance] shopgoods:self.shopInfo.shop_id tagId:@"" sort:@"time" key:@"" page:page block:^(NSError *error, MSNShopDetail* data, id userInfo, BOOL cache) {
        self.messageView.numberLabel.text = [NSString stringWithFormat:@"全部在售商品:%@件",data.goods_num];
        MSNGoodsList *list = [[MSNGoodsList alloc] init];
        list.info = data.info.goods_info;
        list.goods_num = [data.goods_num integerValue];
        list.next_page = data.next_page;
        [self receiveData:list page:page];
    }];
}

- (void)actionShowSearchView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.searchView.top=0;
        self.messageView.top=self.searchView.superview.height;
    }];
}

- (void)searchViewCancelButtonClicked:(MSNSearchView *)searchBar
{
    [UIView animateWithDuration:0.25 animations:^{
        self.searchView.top=-self.searchView.superview.height;
        self.messageView.top=0;
    }];
}

@end
