//
//  AddViewController.m
//  WeChat_XMPP
//
//  Created by hebiao on 15/8/25.
//  Copyright (c) 2015年 Hebiao. All rights reserved.
//

#import "AddViewController.h"
#import "XMPPManager.h"
@interface AddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;

- (IBAction)Search:(id)sender;
- (IBAction)delete:(id)sender;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.view.backgroundColor=[UIColor whiteColor];
   
    
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

- (IBAction)Search:(id)sender {
      [[XMPPManager sharedManager] addFriend:self.userName.text];
}

- (IBAction)delete:(id)sender {
      [[XMPPManager sharedManager] removeFriend:self.userName.text];
}
@end
