//
//  MSImportFavViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-9.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNImportFavViewController.h"
#import "MSFShopInfo.h"
#import "UILabel+Mini.h"
#import "UIColor+Mini.h"
#import "MSUIWebViewController.h"
#import "MSShopInfoCell.h"
#import "MSNShop.h"
#import "MSNShopDetailViewController.h"

@interface MSNImportFavViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic,strong) NSDictionary   *dataSource;
@property (nonatomic,strong) UITableView    *tableView;
@end


@implementation MSNImportFavViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createTableView];
    [self setNaviBackButton];
    self.title =  @"导入收藏夹";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadFavData];
}

- (void)createTableView
{
    self.tableView = [self createPlainTableView];
    [self.contentView addSubview:self.tableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray *)dataSourceAtSection:(NSInteger)section
{
    NSArray *ds = [self.dataSource valueForKey:section==0?@"record":@"norecord"];
    return ds;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) return @"已经收录的商家";
    else return @"未收录的商家";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *ds = [self dataSourceAtSection:section];
    if ( ds.count > 0 ) return 30;
    else return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"web_toolbar_bg_"]];
    view.backgroundColor = bgColor;
    UILabel *label = [UILabel LabelWithFrame:CGRectMake(5, 0, view.width-10, 30) bgColor:bgColor text:[self titleForHeaderInSection:section] color:[UIColor colorWithRGBA:0x785530ff] font:[UIFont boldSystemFontOfSize:16] alignment:NSTextAlignmentLeft shadowColor:nil shadowSize:CGSizeZero];
    label.centerY = view.height/2 + 5;
    [view addSubview:label];
    MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"这是什么>>" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRGBA:0x785530ff] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRGBA:0xffffffff] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.height= view.height;
    button.titleLabel.height = view.height;
    [button sizeToFit];
    button.frame = CGRectMake(view.width - button.width - 10, (view.height-button.height)/2 + 5, button.width, button.height);
    [view addSubview:button];
    __weak typeof (self) pSelf = self;
    [button setTouchupHandler:^(MiniUIButton *button) {
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:@"http://youjiaxiaodian.com/api/help" title:@"" toolbar:NO];
        [pSelf.navigationController pushViewController:controller animated:YES];
    }];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *ds = [self dataSourceAtSection:section];
    return ds.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSFShopInfo *info = [ds objectAtIndex:indexPath.row];
    if ( info.shop_id > 0 ) {
        MSNShopInfo *msnShopInfo = [[MSNShopInfo alloc] init];
        msnShopInfo.shop_id = [NSString stringWithFormat:@"%ld",info.shop_id];
        MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
        controller.shopInfo = msnShopInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        [self actionGoToShopping:info];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSFShopInfo *info = [ds objectAtIndex:indexPath.row];
    return [MSShopInfoCell height:info];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[MSShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [cell.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRGBA:0xefefefff];
    }
    NSArray *ds = [self dataSourceAtSection:indexPath.section];
    MSFShopInfo *info = [ds objectAtIndex:indexPath.row];
    cell.shopInfo = info;
    cell.button.userInfo = info;
    return cell;
}

- (void)loadFavData
{
    __PSELF__;
    [[ClientAgent sharedInstance] importFav:self userInfo:nil block:^(NSError *error, id data, id userInfo,
            BOOL cache) {
        if (error==nil) {
            id list = [data valueForKey:@"resultList"];
            if ( [list isKindOfClass:[NSArray class]])
            {
                [pSelf showWating:nil];
                [[ClientAgent sharedInstance] shopsInfo:list userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                    [pSelf dismissWating];
                    if ( error == nil ) {
                        pSelf.dataSource = data;
                        [pSelf.tableView reloadData];
                    }
                    else {
                        [pSelf showErrorMessage:error];
                    }
                }];
            }
            else {
                [pSelf showMessageInfo:@"发生错误啦" delay:2];
            }
        }
    }];

}

- (void)buttonTap:(__weak MiniUIButton *)button
{
    __PSELF__;
        MSFShopInfo *info = button.userInfo;
        if ( info.shop_id == 0 ) // 收录
        {
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] usercooperate:info userInfo:nil block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if ( error == nil ) {
                    info.like=1;
                    info.cooperate = 1;
                    [UIView animateWithDuration:0.25 animations:^{
                        button.alpha = 0.2;
                    }completion:^(BOOL finished) {
                        button.hidden = YES;
                    }];
                }
                else {
                    [pSelf showErrorMessage:error];
                }
            }];
        }
        else // 关注
        {
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] setfavshop:LLTOS(info.shop_id) action:info.like==0?@"on":@"off" block:^
            (NSError
            *error,
                    id data,
                    id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if (error==nil) {
                    info.like = info.like==0?1:0;
                    [pSelf.tableView reloadData];
                }
                else {
                    [self showErrorMessage:error];
                }
            }];

        }
}
@end