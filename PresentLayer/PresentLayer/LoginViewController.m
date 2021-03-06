//
//  LoginViewController.m
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"
#import "HeadFile.h"

@interface LoginViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加代理
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


/**
 * 登陆按钮方法
 */

- (IBAction)loginButtonAction:(UIButton *)sender
{
    [[XMPPManager sharedManager] loginWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
    
}
- (IBAction)logoutButtonAction:(UIButton *)sender {
      [[XMPPManager sharedManager] logoutWithUserName:self.userNameTextField.text];
}

/**
 * 验证成功
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
      //登录成功消息
      NSLog(@"%s__%d__| 登陆成功", __FUNCTION__, __LINE__);
      [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DID_AUTHENTICATE object:nil userInfo:nil];
      
      XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
      [[XMPPManager sharedManager].xmppStream sendElement:presence];
      
      UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      UIViewController *registerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"FriendListNavigation"];
      [self presentViewController:registerViewController animated:YES completion:^{NSLog(@"go to add friendsList");}];
      
}

/**
 * 登陆失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"%s__%d__|", __FUNCTION__, __LINE__);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
