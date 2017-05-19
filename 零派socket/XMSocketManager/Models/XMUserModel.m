//
//  XMUserModel.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/18.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "XMUserModel.h"


@implementation XMUserModel
- (BOOL)isOwner {
    return [self.is_owner isEqualToString:@"1"];
}

- (NSString *)formatPayMoney {
    if (self.payMoney == nil || self.isOwner) {
        return @" ";
    }
    return [NSString stringWithFormat:@"%@元",self.payMoney];
}
@end
