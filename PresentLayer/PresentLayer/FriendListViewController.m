//
//  FriendListViewController.m
//  PresentLayer
//
//  Created by tiger on 16/8/10.
//  Copyright © 2016年 buystreet. All rights reserved.
//

#import "FriendListViewController.h"
#import "XMPPManager.h"
#import "JSQChatViewController.h"
@interface FriendListViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSString *userStat; //好友状态

@end

@implementation FriendListViewController

- (void)viewDidLoad
{
      [super viewDidLoad];
      
      NSManagedObjectContext *context=[[XMPPManager sharedManager] rosterContext];
      
      NSEntityDescription *entity=[NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
      NSSortDescriptor *sd1=[NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
      NSSortDescriptor *sd2=[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
      
      NSFetchRequest *request=[[NSFetchRequest alloc] init];
      [request setEntity:entity];
      [request setSortDescriptors:@[sd1,sd2]];
      
      fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sectionNum" cacheName:nil];
      fetchedResultsController.delegate=self;
      [fetchedResultsController performFetch:nil];

      //获取属性列表文件中的全部数据
//      self.listTeams;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
      
      
      [self.tableView reloadData];
      
}
#pragma mark --UITableViewDataSource 协议方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
      NSArray *arr=[fetchedResultsController sections];
      
      
      id<NSFetchedResultsSectionInfo>  secetionInfo=arr[section];
      
      return secetionInfo.numberOfObjects;
}
/*
 *设置单元格高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
      
      return 80;
}
/*
 *设置节的数量
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
      
      return [fetchedResultsController sections].count;
      
}
/*
 *节头设置
 */
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//      
//      NSArray *arr=[fetchedResultsController sections];
//      
//      id<NSFetchedResultsSectionInfo>  secetionInfo=arr[section];
//      if ([secetionInfo.name isEqualToString:@"0"]) {
//            return (@"在线");
//      }
//      else if ([secetionInfo.name isEqualToString:@"1"]){
//            return @"离开";
//      }
//      else {
//            return @"离线";
//      }
//      
//      
//      
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      static NSString *CellIdentifier = @"friends";
      
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
      XMPPUserCoreDataStorageObject *user=[fetchedResultsController objectAtIndexPath:indexPath];
      
      
      cell.textLabel.text=user.jid.user;
      
      //获取用户状态
      NSArray *arr=[fetchedResultsController sections];
      id<NSFetchedResultsSectionInfo>  secetionInfo=arr[indexPath.section];
      if ([secetionInfo.name isEqualToString:@"0"]) {
            self.userStat = @"在线";
      }
      else if ([secetionInfo.name isEqualToString:@"1"]){
            self.userStat = @"离开";
      }
      else {
           self.userStat = @"离线";
      }
      cell.detailTextLabel.text=self.userStat;
      
  
      
      
      if (user.photo!=nil) {
            cell.imageView.image=user.photo;
      }else{
            
            NSData *phdata=[[[XMPPManager sharedManager] vatarModule] photoDataForJID:user.jid];
            if (phdata!=nil) {
                  cell.imageView.image=[UIImage imageWithData:phdata];
            }else{
                  cell.imageView.image=[UIImage imageNamed:@"AppIcon@2x.png"];
            }
      }
      
      
      return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      
      XMPPUserCoreDataStorageObject *user=[fetchedResultsController objectAtIndexPath:indexPath];
      
      
      JSQChatViewController *jsc=[[JSQChatViewController alloc] init];
      jsc.hidesBottomBarWhenPushed=YES;
      jsc.currentUser=user;
      [self.navigationController pushViewController:jsc animated:YES];
      
      
}

#pragma mark - Navigation
/*
 *跳转到聊天界面
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
      if([segue.identifier isEqualToString:@"ChartView"])
      {
            ChartViewController *chartViewController = segue.destinationViewController;
            NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow] ;
            XMPPUserCoreDataStorageObject *user=[fetchedResultsController objectAtIndexPath:selectedIndex];
            chartViewController.title =  user.jid.user;
      }
}
*/

@end
