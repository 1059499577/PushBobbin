//
//  XMUserModel.h
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMUserModel : NSObject
@property (nonatomic, copy) NSString *client_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *is_owner;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL isOnSeat;//是否上座
@end
