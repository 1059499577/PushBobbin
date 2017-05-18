//
//  ViewController.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/16.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "ViewController.h"
#import "XMSocketManager.h"
#import "XMGameVC.h"
#import "XMReadyVC.h"
#import "MBProgressHUD+MJ.h"
#import "XMUserTool.h"
#import <MJExtension.h>



@interface ViewController ()<XMSocketManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (nonatomic, strong) XMSocketManager *socketManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.socketManager = [XMSocketManager share];
    self.socketManager.delegate = self;
 }

- (IBAction)connect:(id)sender {
    [self.socketManager connect];
}
- (IBAction)disconnect:(id)sender {
    [self.socketManager disconnect];
}
- (IBAction)sendMessage:(id)sender {
    
    NSString *msg = self.textFiled.text;
    if (msg.length == 0) {
        return;
    }
    [self.socketManager sendMessage:msg];
    self.textFiled.text = @"";
}

- (void)SocketManagerStatusChanged:(SocketStatus)status {
    
    switch (status) {
        case SocketStatus_connecting:
            self.statusLable.text = @"尝试连接中...";
            self.statusLable.textColor = [UIColor blackColor];
            break;
        case SocketStatus_connect:
            self.statusLable.text = @"已连接";
            self.statusLable.textColor = [UIColor greenColor];
            break;
        case SocketStatus_disconnect:
            self.statusLable.text = @"未连接";
            self.statusLable.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
}

- (void)SocketManagerDidReceiveMessage:(NSString *)msg {
   
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    static int a = 0;
    if (a == 1) {
        
    } else if(a == 2) {
       [self.socketManager sendDict:@{@"type":@"start",@"user_id":@"01"}];
    }
}
- (IBAction)login:(id)sender {
    NSString *userID = self.textFiled.text;
    if (userID.length == 0) {
        [MBProgressHUD showError:@"请填写UserID"];
        return;
    }
    if (self.socketManager.socketStatus != SocketStatus_connect) {
        [MBProgressHUD showError:@"请链接网络"];
        return;
    }
    [self.socketManager sendDict:@{@"type":@"login",@"user_id":userID}];
}

- (void)SocketManagerDidReceiveDict:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"login"]) {
        XMUserTool *userTool = [XMUserTool share];
        NSDictionary *tmpDict = dict[@"user"];
        userTool.myUser = [XMUserModel mj_objectWithKeyValues:tmpDict];
        [self presentViewController:[XMReadyVC new] animated:YES completion:^{
            
        }];
    }
}


@end
