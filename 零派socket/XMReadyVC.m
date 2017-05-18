//
//  XMReadyVC.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "XMReadyVC.h"
#import "XMGameVC.h"
#import "XMUserTool.h"
#import "XMSocketManager.h"
#import <MJExtension.h>

@interface XMReadyVC ()<XMSocketManagerDelegate>
@property (nonatomic, strong) XMSocketManager *socketManager;

@end

@implementation XMReadyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.socketManager = [XMSocketManager share];
    self.socketManager.delegate = self;
}

- (IBAction)start:(id)sender {
    NSString *userID = [XMUserTool share].myUser.user_id;
    [self.socketManager sendDict:@{@"type":@"start",@"user_id":userID}];
}

- (void)SocketManagerDidReceiveDict:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"start"]) {
        NSArray *users = dict[@"users"];
        NSArray *userModels = [XMUserModel mj_objectArrayWithKeyValuesArray:users];
        [[XMUserTool share].users removeAllObjects];
        [[XMUserTool share].users addObjectsFromArray:userModels];
        [self presentViewController:[XMGameVC new] animated:YES completion:^{
            
        }];
    }
}


@end
