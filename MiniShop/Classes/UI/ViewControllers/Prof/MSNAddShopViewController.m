//
//  MSNAddShopViewController.m
//  MiniShop
//
//
//
//  Created by Wuquancheng on 14-3-22.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNAddShopViewController.h"
#import "MSNTransformButton.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "MSNShopDetailViewController.h"
#import "MSNImportFavViewController.h"

@interface MSNAddShopViewController () <UITextFieldDelegate,MSNShopInfoCellDelegate,MSTransformButtonDelegate>
@property (nonatomic, strong)UITextField *searchField;
@property (nonatomic, strong)MSNTransformButton *transformButton;
@property (nonatomic, strong)EGOUITableView   *tableView;
@property (nonatomic, strong)MSNShopList   *dataSource;
@property (nonatomic, strong)UIView        *sectionHeaderView;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL dataChanged;
@end

@implementation MSNAddShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataChanged = NO;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    self.title = @"添加商铺";

    [self setNaviRightButtonTitle:@"导入收藏夹" target:self action:@selector(actionImportFav:)];

    self.tableView = [self createEGOTableView];
    [self.contentView addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataSource.info.count>0) {
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_sectionHeaderView==nil){
        _sectionHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 40)];
        _sectionHeaderView.backgroundColor = [self backgroundColor];
        self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(5, 0, 65, 30)];
        self.transformButton.items = @[@"店铺名",@"掌柜名",@"商品名"];
        self.transformButton.values = @[@"1",@"2",@"3"];
        self.transformButton.fontSize = 14;
        self.transformButton.delegate = self;
        self.transformButton.fontColor = [UIColor redColor];
        [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_b"] himage:[UIImage
                imageNamed:@"arrow_b"]];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [view addSubview:self.transformButton];

        CGFloat left = 15;
        self.searchField = [[UITextField  alloc] initWithFrame:CGRectMake(left,5,self.contentView.width-2*left,30)];
        self.searchField.font = [UIFont systemFontOfSize:14];
        self.searchField.backgroundColor = [UIColor clearColor];
        self.searchField.placeholder = @"搜索店铺然后添加";
        [_sectionHeaderView addSubview:self.searchField];
        self.searchField.leftView = view;
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.delegate = self;

    }
    return _sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.info.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSNShopInfo *info = [self.dataSource.info objectAtIndex:indexPath.row];
    return [MSNShopInfoCell height:info];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MSNShopInfo *info = [self.dataSource.info objectAtIndex:indexPath.row];
    MSNShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil ) {
        cell = [[MSNShopInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.shopInfoDelegate = self;
        cell.backgroundColor = [self backgroundColor];
    }
    cell.shopInfo = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
    controller.shopInfo = [self.dataSource.info objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self search:1];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)receiveData:(MSNShopList *)data page:(int)page
{
    _page = page;
    if ( page == 1) {
        [self.tableView refreshDone];
        self.dataSource = data;
    }
    else {
        [self.dataSource append:data];
    }
    [self.tableView reloadData];
    [self setMoreDataAction:(data.next_page==1) tableView:self.tableView];
    [self.tableView reloadData];
}

- (void)loadMore
{
    [self search:(_page+1)];
}

- (void)search:(NSInteger)page
{
    [self.searchField resignFirstResponder];
    NSString *key = self.searchField.text;
    if (key.length>0) {
        NSString *value = self.transformButton.selectedValue;
        __PSELF__;
        [self showWating:nil];
        [[ClientAgent sharedInstance] searchshop:key type:value page:page block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if (error==nil) {
                [pSelf receiveData:data page:page];
            }
        }];
    }
}

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    [self search:1];
}


- (void)favShop:(MSNShopInfo*)shopInfo
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            shopInfo.user_like = 1;
            [pSelf.tableView reloadData];
            _dataChanged = YES;
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)cancelFavShop:(MSNShopInfo*)shopInfo
{
    [self showWating:nil];
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:shopInfo.shop_id action:@"off" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            shopInfo.user_like = 0;
            [pSelf.tableView reloadData];
        }
        else {
            [self showErrorMessage:error];
        }
    }];
}

- (void)actionImportFav:(MiniUIButton *)button
{
    MSNImportFavViewController *controller = [[MSNImportFavViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)back
{
    if (_dataChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_FAV_CHANGE object:nil];
    }
    [super back];
}

@end
