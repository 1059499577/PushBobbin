//
//  XMUserTool.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "XMUserTool.h"

@implementation XMUserTool
+ (instancetype)share {
    static dispatch_once_t onceToken;
    static XMUserTool *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[XMUserTool alloc] init];
    });
    return instance;
}


- (NSMutableArray *)users {
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    return _users;
}
@end
