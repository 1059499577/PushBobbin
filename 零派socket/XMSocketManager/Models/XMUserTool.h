//
//  XMUserTool.h
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMUserModel.h"

#define kLeftUserComming @"kLeftUserComming"
#define kRightUserComming @"kRightUserComming"

@interface XMUserTool : NSObject
@property (nonatomic, strong) XMUserModel *myUser;
@property (nonatomic, strong) XMUserModel *leftUser;
@property (nonatomic, strong) XMUserModel *rightUser;
@property (nonatomic , retain)NSMutableArray *users;
@property (nonatomic, copy) NSString *room_id;
- (void)reloadUser;
+ (instancetype)share;
/* 返回值为是否平家全部押注完毕 */
- (BOOL)payMoney:(NSString *)money withUserID:(NSString *)userID;

- (void)resetUsers;

- (void)putCardsWithArray:(NSArray *)array;
@end
