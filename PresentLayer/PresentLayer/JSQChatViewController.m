//
//  ChatDetailViewController.m
//  WeChat_XMPP
//
//  Created by hebiao on 15/8/25.
//  Copyright (c) 2015年 Hebiao. All rights reserved.
//

#import "JSQChatViewController.h"
#import "XMPPFramework.h"
#import "HeadFile.h"
#import "AppDelegate.h"

#import "DDLog.h"
#import "NSDate+XMPPDateTimeProfiles.h"

#import "JSQChatViewController.h"
#import "XMPPManager.h"
#import "EnlargeImage.h"


@interface JSQChatViewController ()

@end

@implementation JSQChatViewController

- (void)viewDidLoad {
      [super viewDidLoad];
      // Do any additional setup after loading the view.

      messagesList=[[NSMutableArray alloc] init];

      self.title=self.currentUser.jid.user;
      self.collectionView.collectionViewLayout.springinessEnabled = NO;

      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciviedMsg:) name:NOTICE_RECIVED_MSG_5 object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStat:) name:NOTICE_NETWORK_DISCONNECT object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticate:) name:NOTICE_DID_AUTHENTICATE object:nil];

      self.senderDisplayName=self.currentUser.displayName;
      self.senderId=self.currentUser.jid.user;


      JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];

      inBubbleImage=[bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
      outBubbleImage=[bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
      
      //增加“删除”
       [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

      //通信对象的头像
      NSData *photoData = [[[XMPPManager sharedManager]vatarModule] photoDataForJID:self.currentUser.jid];
      if (photoData != nil){
         inAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:photoData] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
      }

      else{
          inAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"AppIcon@2x.png"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
      }
      
      //自己的头像
      XMPPJID *jid=[XMPPJID jidWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"]];
      photoData = [[[XMPPManager sharedManager] vatarModule] photoDataForJID:jid];


      if (photoData != nil){
        outAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:photoData] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
      }

      else{
        outAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"AppIcon@2x.png"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
      }

    
    
    /*
    inAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"AppIcon"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    outAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"AppIcon"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    */
    
}


-(void)viewDidAppear:(BOOL)animated{
      [super viewDidAppear:YES];
      [self controllerDidChangeContent:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    
    
    for (id <NSFetchedResultsSectionInfo> sectionInfo in sections) {
        
                
    }
    
    
    
}

//获取好友列表的结果控制对象
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultController == nil)
    {
        NSManagedObjectContext *moc = [[XMPPManager sharedManager] messageContext];
        
        //数据存储实体（表）
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                  inManagedObjectContext:moc];
        
        //设置结果的排序规则
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr=%@", self.currentUser.jid.user];
        
        //数据请求
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        [_fetchedResultController setDelegate:self];
        
        
        NSError *error = nil;
        //开始请求数据
        if (![_fetchedResultController performFetch:&error])
        {
              NSLog(@"聊天数据请求失败");
        }
        
    }
    
    return _fetchedResultController;
}
/** 发送二进制文件 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
      //调用jsqmessagesViewControll显示
      JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:data]];
      JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                     displayName:self.senderDisplayName
                                                           media:photoItem];
      
      [messagesList addObject:photoMessage];
      [self finishSendingMessageAnimated:YES];
      
      //发送
      [[XMPPManager sharedManager] sendMessageWithData:data bodyName:name toUser:self.currentUser.jid];
     
}

-(void)didPressAccessoryButton:(UIButton *)sender{
    
      UIActionSheet *actionSheet =[ [UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照片",@"拍照",nil];
      actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
      [actionSheet showInView:self.view];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
 
//    [JSQSystemSoundPlayer jsq_playMessageSentSound];
 
    JSQMessage *message = [JSQMessage messageWithSenderId:senderId
                                              displayName:senderDisplayName
                                                     text:text];
  
    [messagesList addObject:message];
  
    [self finishSendingMessageAnimated:YES];
   
//    [self receiveAutoMessage];
    
    [[XMPPManager sharedManager]sendMessage:text toUser:self.currentUser.jid];
    
    
    
}
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [messagesList objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messagesList objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return outBubbleImage;
    }
    return inBubbleImage;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messagesList objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return outAvatarImage;
    }
    return inAvatarImage;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return messagesList.count;
}



- (void)receiveAutoMessage
{
 
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(didFinishMessageTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

/**
 *接收到消息通知的处理函数
 */
-(void)reciviedMsg:(NSNotification *)sender{
      NSDictionary *dic=sender.userInfo;
      [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
      
      //显示图片
      if ([[dic objectForKey:@"body"] isEqualToString:@"image"]) {
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:[dic objectForKey:@"image"] options:0];
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
            JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                           displayName:self.senderDisplayName
                                                                 media:photoItem];

            [messagesList addObject:photoMessage];
            
      }
      //显示文字
      else{
            JSQMessage *message = [JSQMessage messageWithSenderId:@"user2"
                                              displayName:dic[@"display"]
                                                     text:dic[@"body"]];
            [messagesList addObject:message];
      }

      [self finishReceivingMessageAnimated:YES];

}

/**
 *接收到网络连接失败消息的处理函数
 */
-(void)networkStat:(NSNotification *)sender{
      self.title = @"网络断开，正在重连....";
}
/**
 *接收到网络登录成功消息的处理函数
 */
-(void)didAuthenticate:(NSNotification *)sender{
      self.title = self.currentUser.jid.user;
}


#pragma  mark-- 实现UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
      NSLog(@"the click button is :%i",(int)buttonIndex);
      
      //选择照片
      if (buttonIndex == 0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
           
      }
      
      //选择拍照
      else if (buttonIndex == 1) {
            
      }
      
      ///选择取消
      else{
            
      }
}

#pragma mark - ******************** imgPickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
      UIImage *image = info[UIImagePickerControllerOriginalImage];

      NSData *data = UIImageJPEGRepresentation(image, 0.1);
      [self dismissViewControllerAnimated:YES completion:nil];

      
//      _concurent_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//      dispatch_async(_concurent_queue, ^{
//            [self sendMessageWithData:data bodyName:@"image"];}
//            );
      
      [self sendMessageWithData:data bodyName:@"image"];
      
     
}
//数据源协议，删除消息
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
      [messagesList removeObjectAtIndex:indexPath.item];
}

- (void)didFinishMessageTimer:(NSTimer*)timer
{
 
//    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    JSQMessage *message = [JSQMessage messageWithSenderId:@"user2"
                                              displayName:@"underscore"
                                                     text:@"Hello"];
    [messagesList addObject:message];
    
    [self finishReceivingMessageAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
      NSLog(@"Load earlier messages!");
      
      

}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
      NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
      NSLog(@"Tapped message bubble!");
      JSQMessage *message = [messagesList objectAtIndex:indexPath.item];
      JSQPhotoMediaItem *photoItem = message.media;
       //跳转到enlargImage
      if ([message.media isKindOfClass:[JSQPhotoMediaItem class]]) {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            EnlargeImage *registerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"EnlargeImage"];
            UIImage *image = [photoItem image];
            registerViewController.photo = [photoItem image];
            [self presentViewController:registerViewController animated:YES completion:^{NSLog(@"go to add enlargImage");}];
      }
      
     
     
      
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
      NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
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
