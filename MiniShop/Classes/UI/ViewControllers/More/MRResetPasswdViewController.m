//
//  MRResetPasswdViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-9-18.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MRResetPasswdViewController.h"
#import "MiniUIASTextField.h"
#import "UITextField+Mini.h"

@interface MRResetPasswdViewController ()<UITextFieldDelegate>
@property (nonatomic,strong)UITextField *nameField;
@property (nonatomic,strong)UITextField *mobileField;
@end

@implementation MRResetPasswdViewController

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
    [self setNaviRightButtonTitle:@"找回密码" target:self action:@selector(actionResetPasswd)];
    
    UIScrollView *scrollveiw = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollveiw.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:scrollveiw];
    
    self.nameField = [[MiniUIASTextField alloc] initWithFrame:CGRectMake(20, 20, self.view.width-40, 28)];
    [self.nameField  setLeftTitle:@"用  户  名" color:[UIColor grayColor] placeholder:@"请输入用户名"];
    [self.nameField  setBottomLine:[UIColor grayColor]];
    self.nameField .returnKeyType = UIReturnKeyNext;
    [scrollveiw addSubview:self.nameField ];
    self.nameField.delegate = self;
    self.nameField.text = @"wolfxy_a";
    
    self.mobileField =  [[MiniUIASTextField alloc] initWithFrame:CGRectMake(20, self.nameField.bottom + 10, self.view.width-40, 28)];
    [self.mobileField setLeftTitle:@"手机号码" color:[UIColor grayColor] placeholder:@"请输入联系方式"];
    [self.mobileField setBottomLine:[UIColor grayColor]];
    self.mobileField.returnKeyType = UIReturnKeyDone;
    self.mobileField.delegate = self;
    [scrollveiw addSubview:self.mobileField];
    
    scrollveiw.contentSize = CGSizeMake(self.view.width, self.view.height+1);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@"\n"] ) {
        if ( textField == self.nameField ) {
            [self.mobileField becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
            [self actionResetPasswd];
        }
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"找回密码";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionResetPasswd
{
    NSString *name = self.nameField.text;
    NSString *mobile = self.mobileField.text;
    if ( name.length==0 || mobile.length==0) {
        [self showMessageInfo:@"用户名联系信息错误" delay:2];
        return;
    }
    else {
        __PSELF__;
        WHO = nil;
        [self.view endEditing:YES];
        [self showWating:nil];
        [[ClientAgent sharedInstance] resetpasswd:name mobile:mobile block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error != nil ) {
                [pSelf showErrorMessage:error];
            }
            else {
                NSString *msg = data.show_msg;
                if ( msg.length == 0) {
                    msg = @"我们已经开始给您找密码啦";
                }
                [self showMessageInfo:msg delay:2];
            }
        }];
    }
    
}

@end
