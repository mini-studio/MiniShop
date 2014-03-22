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
#import "MSNUISearchBar.h"
#import "MSNTransformButton.h"

@interface MSNAddShopViewController () <UITextFieldDelegate>
@property (nonatomic,strong)UITextField *searchField;
@property (nonatomic,strong)MSNTransformButton *transformButton;
@end

@implementation MSNAddShopViewController

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
    [self setNaviBackButton];
    self.title = @"添加商铺";

    self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(5, 0, 65, 30)];
    self.transformButton.items = @[@"店铺名",@"掌柜名",@"商品名"];
    self.transformButton.fontSize = 14;
    self.transformButton.delegate = self;
    self.transformButton.fontColor = [UIColor redColor];
    [self.transformButton setAccessoryImage:[UIImage imageNamed:@"arrow_b"] himage:[UIImage
            imageNamed:@"arrow_b"]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [view addSubview:self.transformButton];

    CGFloat left = 15;
    self.searchField = [[UITextField  alloc] initWithFrame:CGRectMake(left,left,self.contentView.width-2*left,30)];
    self.searchField.font = [UIFont systemFontOfSize:14];
    self.searchField.backgroundColor = [UIColor whiteColor];
    self.searchField.placeholder = @"搜索店铺然后添加";
    [self.contentView addSubview:self.searchField];
    self.searchField.leftView = view;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self doSearch:textField.text];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)doSearch:(NSString*)key
{
    [self.searchField resignFirstResponder];
    if (key.length>0) {

    }

}


@end
