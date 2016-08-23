//
//  ChatDetailViewController.h
//  WeChat_XMPP
//
//  Created by hebiao on 15/8/25.
//  Copyright (c) 2015年 Hebiao. All rights reserved.
//

#import "JSQMessages.h"
#import <CoreData/CoreData.h>
@class XMPPUserCoreDataStorageObject;


@interface JSQChatViewController : JSQMessagesViewController<NSFetchedResultsControllerDelegate,JSQMessagesCollectionViewDataSource,JSQMessagesCollectionViewDelegateFlowLayout,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
      NSFetchedResultsController *_fetchedResultController;

      JSQMessagesAvatarImage *inAvatarImage;
      JSQMessagesAvatarImage *outAvatarImage;


      JSQMessagesBubbleImage *inBubbleImage;
      JSQMessagesBubbleImage *outBubbleImage;


      NSMutableArray *messagesList;
      
      //创建并发队列
      dispatch_queue_t _concurent_queue;

}



@property (strong,nonatomic) XMPPUserCoreDataStorageObject *currentUser;

@end
