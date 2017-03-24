//
//  MQSocketClient.m
//  testSocketClient
//
//  Created by mac on 17/3/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MQSocketClient.h"

#define HOST @"127.0.0.1"
#define PORT 8080

//设置读取超时 -1 表示不会使用超时
#define READ_TIME_OUT -1

//设置写入超时 -1 表示不会使用超时
#define WRITE_TIME_OUT -1

//每次最多读取多少
#define MAX_BUFFER 1024
static MQSocketClient *socketClient = nil;

@implementation MQSocketClient

+(instancetype) shareSocketClient
{
    
    
    dispatch_once_t oneTaken;
    dispatch_once(&oneTaken, ^{
        if (socketClient == nil)
        {
            socketClient = [[MQSocketClient alloc] init];
        }
        
    });
    
    return socketClient;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (socketClient == nil)
        {
            socketClient = [super allocWithZone:zone];
            return socketClient;
        }
    }
    return nil;
}



-(void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    if (![self socketOpen:HOST port:PORT])
    {
        NSLog(@"已经连接");
    }
}

-(BOOL) socketOpen:(NSString *) addr port:(NSInteger) port
{
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:20 error:&error];
        return YES;
    }
    
    return NO;
}

-(void)closeSocketConnect
{
    if([self.socket isConnected])
    {
        self.socket.userData = SOCKET_OFFLINE_USER;
        [self.socket disconnect];
    }
}


-(void)sendMessage:(NSString *)message
{
    if ([self.socket isConnected])
    {
        NSData *data =[message dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:1 tag:1];
    }
    
}

-(void)sendImageMessage:(id)message
{
    
}


#pragma mark AsyncSocketDelegate

-(void) onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@" connect is error :%ld",sock.userData);
    
    if (sock.userData == SOCKET_OFFLINE_CLIENT)
    {
        [self startConnectSocket];
    }
    else
    {
        return ;
    }
}

-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"连接成功");
    
//    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkLongConnectByServer) userInfo:nil repeats:YES];
//    [self.heartTimer fire];
}

// 心跳连接
-(void) checkLongConnectByServer
{
    NSString *longConnect = @"hello server";
    NSData   *data  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:1 tag:1];
}

//接受消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //服务端返回消息数据量比较大时，可能分多次返回。所以在读取消息的时候，设置MAX_BUFFER表示每次最多读取多少，当data.length < MAX_BUFFER我们认为有可能是接受完一个完整的消息，然后才解析
    if( data.length < MAX_BUFFER )
    {
        //收到结果解析...
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"dic %@",dic);
        //解析出来的消息，可以通过通知、代理、block等传出去
        
    }
    
    
    [self.socket readDataWithTimeout:READ_TIME_OUT buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
    
}


//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"发送消息成功");
    
    //读取消息
    [self.socket readDataWithTimeout:-1 buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
}


@end
