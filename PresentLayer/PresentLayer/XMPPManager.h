//
//  XMPPManager.h
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@class NSManagedObjectContext;
@class XMPPvCardAvatarModule;
@class XMPPJID;
@class XMPPStream;

@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

// 通信通道对象
@property (nonatomic, strong) XMPPStream *xmppStream;
//好友花名册管理
@property (nonatomic,strong)  XMPPRoster *xmppRoster;
+ (XMPPManager *)sharedManager;

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password;

- (void)registerWithUserName:(NSString *)userName
                    password:(NSString *)password;
- (void)logoutWithUserName:(NSString *)userName;
- (void)addFriend:(NSString *)userName;
- (void)removeFriend:(NSString *)userName;
-(NSManagedObjectContext *)rosterContext;
-(XMPPvCardAvatarModule *)vatarModule; 
- (NSManagedObjectContext *)messageContext;
-(void)sendMessage:(NSString *)msgBody toUser:(XMPPJID *)jid;
@end
