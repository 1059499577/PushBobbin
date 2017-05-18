//
//  XMUserTool.h
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMUserModel.h"
@interface XMUserTool : NSObject
@property (nonatomic, strong) XMUserModel *myUser;
@property (nonatomic , retain)NSMutableArray *users;
@property (nonatomic, copy) NSString *room_id;

+ (instancetype)share;
@end
