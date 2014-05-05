//
//  MRLoginViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-18.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MRLoginViewController.h"
#import "MiniUIASTextField.h"
#import "UITextField+Mini.h"
#import "MRResetPasswdViewController.h"
#import "UIColor+Mini.h"

@interface MRLoginViewController ()<UITextFieldDelegate>
@property (nonatomic,strong)UITextField *nameField;
@property (nonatomic,strong)UITextField *passwdField;
@property (nonatomic,strong)UITextField *mobileField;
@property (nonatomic)int type;
@end

@implementation MRLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.type = 0;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviRightButtonTitle:self.type==0?@"登录":@"注册" target:self action:self.type==0?@selector(actionLogin):@selector(actionReg)];
    
    UIScrollView *scrollveiw = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollveiw.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:scrollveiw];
    
    self.nameField = [[MiniUIASTextField alloc] initWithFrame:CGRectMake(20, 20, self.contentView.width-40, 28)];
    [self.nameField  setLeftTitle:@"用  户  名" color:[UIColor whiteColor] placeholder:@"请输入用户名"];
    [self.nameField  setBottomLine:[UIColor whiteColor]];
    self.nameField .returnKeyType = UIReturnKeyNext;
    [scrollveiw addSubview:self.nameField ];
    self.nameField.delegate = self;
    //self.nameField.text = @"wolfxy_a";
    
    self.passwdField = [[MiniUIASTextField alloc] initWithFrame:CGRectMake(20, self.nameField.bottom + 10, self.contentView.width-40, 28)];
    [self.passwdField setLeftTitle:@"密       码" color:[UIColor whiteColor] placeholder:@"请输入密码"];
    [self.passwdField setBottomLine:[UIColor whiteColor]];
    self.passwdField.returnKeyType = self.type==0?UIReturnKeyDone:UIReturnKeyNext;
    self.passwdField.delegate = self;
    self.passwdField.secureTextEntry = YES;
    //self.passwdField.text = @"wolfxy789456123";
    [scrollveiw addSubview:self.passwdField];
    
    if ( self.type == 0 ) {
        MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitle:@"新用户注册" forState:UIControlStateNormal];
        [button sizeToFit];
        button.width +=10;
        [button setBottomLine:[UIColor whiteColor]];
        button.center = CGPointMake(scrollveiw.width/2, scrollveiw.height-200);
        [button addTarget:self action:@selector(actionToRegiste:) forControlEvents:UIControlEventTouchUpInside];
        [scrollveiw addSubview:button];
    }
    else {
        self.mobileField =  [[MiniUIASTextField alloc] initWithFrame:CGRectMake(20, self.passwdField.bottom + 10, self.contentView.width-40, 28)];
        [self.mobileField setLeftTitle:@"手机号码" color:[UIColor whiteColor] placeholder:@"可以找回密码哟"];
        [self.mobileField setBottomLine:[UIColor whiteColor]];
        self.mobileField.returnKeyType = UIReturnKeyDone;
        self.mobileField.delegate = self;
        [scrollveiw addSubview:self.mobileField];
    }
    
    scrollveiw.contentSize = CGSizeMake(self.contentView.width, self.contentView.height+1);

    if ( self.navigationController.viewControllers.count>1) {
        [self setNaviBackButton];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@"\n"] ) {
        if ( textField == self.nameField ) {
            [self.passwdField becomeFirstResponder];
        }
        else if (  textField == self.passwdField && self.mobileField!=nil ) {
            [self.mobileField becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
            if ( self.type == 0 )
                [self actionLogin];
            else
                [self actionReg];
        }
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = self.type==0?@"登录":@"注册";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionLogin
{
    NSString *name = self.nameField.text;
    NSString *passwd = self.passwdField.text;
    if ( name.length==0 || passwd.length==0) {
        [self showMessageInfo:@"用户名密码错误" delay:2];
        return;
    }
    else {
        __PSELF__;
        [self showWating:nil];
        [self.contentView endEditing:YES];
        [[ClientAgent sharedInstance] login:name passwd:passwd block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil ) {
                if ( self.loginblock ) {
                    self.loginblock(YES);
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_USER_LOGIN object:nil];
                    [self back];
                }
            }
            else {
                [pSelf showErrorMessage:error];
            }
        }];
    }
}

- (void)actionReg
{
    NSString *name = self.nameField.text;
    NSString *passwd = self.passwdField.text;
    if ( name.length==0 || passwd.length==0) {
        [self showMessageInfo:@"用户名密码错误" delay:2];
        return;
    }
    else {
        __PSELF__;
        WHO = nil;
        [self.contentView endEditing:YES];
        [self showWating:nil];
        [[ClientAgent sharedInstance] registe:name passwd:passwd mobile:self.mobileField.text block:^(NSError *error, id data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil ) {
                if ( self.loginblock ) {
                    self.loginblock(YES);
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_USER_LOGIN object:nil];
                    [self back];
                }
            }
            else {
                [pSelf showErrorMessage:error];
            }
        }];
    }

}

- (void)actionForgotPasswd:(MiniUIButton*)button
{
    MRResetPasswdViewController *controller = [[MRResetPasswdViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionToRegiste:(MiniUIButton*)button
{
    MRLoginViewController *controller = [[MRLoginViewController alloc] init];
    controller.type = 1;
    UINavigationController *navi = self.navigationController;
    [navi popViewControllerAnimated:NO];
    [navi pushViewController:controller animated:YES];
}

@end
