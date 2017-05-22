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

- (void)reloadUser {
    if (self.myUser == nil) {
        return;
    }
    for (XMUserModel *user in self.users) {
        if ([user.user_id isEqualToString:self.myUser.user_id]) {
            self.myUser = user;
            user.isOnSeat = YES;
            continue;
        }
        if (self.leftUser != nil && self.leftUser.user_id == user.user_id) {
            self.leftUser = user;
            user.isOnSeat = YES;
            continue;
        }
        if (self.rightUser != nil && self.rightUser.user_id == user.user_id) {
            self.rightUser = user;
            user.isOnSeat = YES;
            continue;
        }
        
        if (self.leftUser == nil) {
            XMUserModel *leftUser = [self lastNotOnSeatUserInUsers:self.users];
            if (leftUser == nil) {
                return;
            } else {
                self.leftUser = leftUser;
                self.leftUser.isOnSeat = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kLeftUserComming object:nil];
                continue;
            }
        }
        
        if (self.rightUser == nil) {
            XMUserModel *rightUser = [self lastNotOnSeatUserInUsers:self.users];
            if (rightUser == nil) {
                return;
            } else {
                self.rightUser = rightUser;
                self.rightUser.isOnSeat = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRightUserComming object:nil];
                continue;
            }
        }  
    }
}

- (XMUserModel *)lastNotOnSeatUserInUsers:(NSArray<XMUserModel *>*)userArray {
    for (XMUserModel *user in userArray) {
        if (user.isOnSeat == NO) {
            return user;
        }
    }
    return nil;
}

- (NSMutableArray *)users {
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    return _users;
}

- (BOOL)payMoney:(NSString *)money withUserID:(NSString *)userID {
    for (XMUserModel *user in self.users) {
        if ([user.user_id isEqualToString:userID]) {
            user.payMoney = money;
        }
    }
    for (XMUserModel *user in self.users) {
        if (user.isOwner == NO && user.payMoney == nil) {
            return NO;
        }
    }
    return YES;  
}

- (void)resetUsers {
    for (XMUserModel *user in self.users) {
        user.payMoney = nil;
        user.result = nil;
        user.cards = nil;
        
    }
}

- (void)putCardsWithArray:(NSArray *)array {
    for (NSDictionary *userDict in array) {
        for (XMUserModel *user in self.users) {
            if ([user.user_id isEqualToString:userDict[@"user_id"]]) {
                user.cards = userDict[@"cards"];
                user.money = [NSString stringWithFormat:@"%@",userDict[@"money"]];
                user.result = userDict[@"resault"];
                user.payMoney = nil;
                break;
            }
        }
    }
}
@end
