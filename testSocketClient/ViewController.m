//
//  ViewController.m
//  testSocketClient
//
//  Created by mac on 17/3/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "MQSocketClient.h"

@interface ViewController ()

@property (nonatomic,strong) MQSocketClient *socketClient;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self startConnectServer];
}

-(void) startConnectServer
{
    _socketClient = [MQSocketClient shareSocketClient];
    //socket连接前先断开连接以免之前socket连接没有断开导致闪退
    [_socketClient closeSocketConnect];
    _socketClient.socket.userData = SOCKET_OFFLINE_CLIENT;
    [_socketClient startConnectSocket];
    
    
}
- (IBAction)onSend:(UIButton *)sender
{
    NSString *text = self.textField.text;
    
    if (text.length>0)
    {
        //发送消息 ，具体根据服务端的消息格式
        
        [_socketClient sendMessage:text];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
