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


@interface JSQChatViewController : JSQMessagesViewController<NSFetchedResultsControllerDelegate,JSQMessagesCollectionViewDataSource,JSQMessagesCollectionViewDelegateFlowLayout,UITextViewDelegate>{
    NSFetchedResultsController *_fetchedResultController;
    
    JSQMessagesAvatarImage *inAvatarImage;
    JSQMessagesAvatarImage *outAvatarImage;
    
    
    JSQMessagesBubbleImage *inBubbleImage;
    JSQMessagesBubbleImage *outBubbleImage;
    
    
    NSMutableArray *messagesList;
    
}



@property (strong,nonatomic) XMPPUserCoreDataStorageObject *currentUser;

@end
