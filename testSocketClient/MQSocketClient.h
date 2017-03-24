//
//  MQSocketClient.h
//  testSocketClient
//
//  Created by mac on 17/3/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

enum{
    SOCKET_OFFLINE_CLIENT, //客户端掉线
    SOCKET_OFFLINE_USER,  //用户断开
    SOCKET_OFFLINE_WIFICUT, // Wi-Fi断开
    SOCKET_OFFLINE_NETWORK   //移动网络断开
};

@interface MQSocketClient : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket         *socket;       // socket
@property (nonatomic, retain) NSTimer             *heartTimer;   // 心跳计时器


+(instancetype) shareSocketClient;

//开始socket连接
-(void) startConnectSocket;

//关闭socket连接
-(void) closeSocketConnect;

//发送文本消息
-(void) sendMessage:(NSString *) message;

//发送图片消息
-(void) sendImageMessage:(id) message;

@end
