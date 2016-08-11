//
//  XMPPManager.m
//  LO_XMPP01
//
//  Created by 张正 on 15/9/19.
//  Copyright (c) 2015年 张正. All rights reserved.
//

#import "XMPPManager.h"
#import "HeadFile.h"

// 枚举
typedef NS_ENUM(NSInteger, ConnectToServerPurpose)
{
    ConnectToServerPurposeLogin,
    ConnectToServerPurposeRegister
};

@interface XMPPManager (){
      XMPPvCardTempModule *_vmodule;
       XMPPvCardAvatarModule *_xmppAvate;
}

@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) ConnectToServerPurpose connectToServerPurpose;

@end

@implementation XMPPManager

/**
 * 创建单例
 */
+ (XMPPManager *)sharedManager
{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
    });
    return manager;
}

/**
 * 初始化方法
 */
- (instancetype)init
{
    if (self = [super init]) {
        // 创建通信通道对象
        self.xmppStream = [[XMPPStream alloc] init];
        // 设置服务器IP地址
        self.xmppStream.hostName = kHostName;
        // 设置服务器端口
        self.xmppStream.hostPort = kHostPort;
        // 添加代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
          [self configure];
    }
    return self;
}
/*
 *激活xmppRoster
 **/
-(void)configure{
      XMPPRosterCoreDataStorage *storage=[XMPPRosterCoreDataStorage sharedInstance];
      _xmppRoster=[[XMPPRoster alloc] initWithRosterStorage:storage];
      //    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests=NO;
      [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
      
      [_xmppRoster activate:_xmppStream];
      
      
      XMPPvCardCoreDataStorage *vStorage=[XMPPvCardCoreDataStorage sharedInstance];
      _vmodule=[[XMPPvCardTempModule alloc] initWithvCardStorage:vStorage];
      [_vmodule activate:_xmppStream];
      
      
      _xmppAvate=[[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vmodule];
      [_xmppAvate activate:_xmppStream];
}


/**
 * 登陆方法
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password
{
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    self.password = password;
    // 连接服务器
    [self connectToServerWithUserName:userName];
}

/**
 * 注册方法
 */
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password
{
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    self.password = password;
    [self connectToServerWithUserName:userName];
}

/**
 * 连接服务器
 */
- (void)connectToServerWithUserName:(NSString *)userName
{
    // 创建XMPPJID对象,JID－格式必须为 "用户名"+"@"+"服务器地址",示例 :user@127.0.0.1
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    // 设置通信通道对象的JID
    self.xmppStream.myJID = jid;
    
    // 发送请求
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        // 先发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        
        // 断开连接
        [self.xmppStream disconnect];
    }
    
    // 向服务器发送请求
    NSError *error = nil;
    
    [self.xmppStream connectWithTimeout:-1 error:&error];
    
    if (error != nil) {
        NSLog(@"%s__%d__%@| 连接失败", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
}

/**
 * 连接超时方法
 */
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"%s__%d__| 连接服务器超时", __FUNCTION__, __LINE__);
}

/**
 * 连接成功
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    switch (self.connectToServerPurpose) {
        case ConnectToServerPurposeLogin:
            [self.xmppStream authenticateWithPassword:self.password error:nil];
            break;
        case ConnectToServerPurposeRegister:
            [self.xmppStream registerWithPassword:self.password error:nil];
            
        default:
            break;
    }
    
    
    
}
/**
 *注销登录
 */
- (void)logoutWithUserName:(NSString *)userName{
      // 创建XMPPJID对象,JID－格式必须为 "用户名"+"@"+"服务器地址",示例 :user@127.0.0.1
      XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
      // 设置通信通道对象的JID
      self.xmppStream.myJID = jid;
      if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
      // 先发送下线状态
            XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
            [self.xmppStream sendElement:presence];

      // 断开连接
            [self.xmppStream disconnect];
            NSLog(@"%s__%d__| 登出成功", __FUNCTION__, __LINE__);
      }
      else{
            NSLog(@"%s__%d__| 请先登录", __FUNCTION__, __LINE__);
      }
      
}
/*
 *增加好友
 */
-(void)addFriend:(NSString *)userName{
      XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
      [_xmppRoster subscribePresenceToUser:jid];
}

/*
 *删除好友
 */
-(void)removeFriend:(NSString *)userName{
      XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
      [_xmppRoster removeUser:jid];
}
/*
 *花名册上下文
 */
-(NSManagedObjectContext *)rosterContext{
      
      XMPPRosterCoreDataStorage *storage=_xmppRoster.xmppRosterStorage;
      return [storage mainThreadManagedObjectContext];
}
/*
 *用户头像
 */
-(XMPPvCardAvatarModule *)vatarModule{
      
      return _xmppAvate;
      
}
/*
 *激活消息模块
 */
- (NSManagedObjectContext *)messageContext
{
      XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
      return [storage mainThreadManagedObjectContext];
}
/*
 *发送消息
 **/
-(void)sendMessage:(NSString *)msgBody toUser:(XMPPJID *)jid{
      NSString *siID = [XMPPStream generateUUID];
      XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:jid elementID:siID];
      NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
      [msg addChild:receipt];
      [msg addBody:msgBody];
      [_xmppStream sendElement:msg];
}

/*
 *当接收到 message 标签的内容时，XMPPFramework 框架回调该方法
 */
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
      NSXMLElement *request = [message elementForName:@"request"];//回执判断
      if (request){
            if ([request.xmlns isEqualToString:@"urn:xmpp:receipts"]){//消息回执
                  //组装消息回执
                  XMPPMessage *msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@"type"] to:message.from elementID:[message attributeStringValueForName:@"id"]];
                  NSXMLElement *recieved = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
                  [msg addChild:recieved];
                  
                  //发送回执
                  [self.xmppStream sendElement:msg];
            }
      }
      else{
            NSXMLElement *received = [message elementForName:@"received"];
            if (received){
                  if ([received.xmlns isEqualToString:@"urn:xmpp:receipts"]){//消息回执
                        //发送成功
                        NSLog(@"message send success!");
                  }
            }
      }
      NSString *body = [[message elementForName:@"body"] stringValue];
      NSString *displayName = [[message from]bare];
      if (body!=nil) {
            NSDictionary *info=@{@"userId":message.from.user,@"display":displayName,@"msg":body};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RECIVED_MSG_5 object:nil userInfo:info];
      }
}

/*
 *当接收到 presence 标签的内容时，XMPPFramework 框架回调该方法
 available 上线
 away 离开
 do not disturb 忙碌
 unavailable 下线
 **/
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
      
      //    NSLog(@"=================%@=",presence);
      NSString *type=[presence type];
      
      //对方已删除好友
      if ([type isEqualToString:@"unsubscribe"]) {
            [_xmppRoster removeUser:presence.from];
      }
     }

/*
 *收到SubscriptionRequest时，XMPPFramework会回调
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
      //接收添加好友请求
      [_xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
      
}
@end
