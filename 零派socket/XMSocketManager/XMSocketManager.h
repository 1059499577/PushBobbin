//
//  XMSocketManager.h
//  零派socket
//
//  Created by RenXiangDong on 2017/5/16.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//


#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, SocketStatus) {
    SocketStatus_connect,
    SocketStatus_disconnect,
    SocketStatus_disconnectByUser,//主动断开
    SocketStatus_connecting,//正在尝试连接开
};
@protocol XMSocketManagerDelegate <NSObject>

@optional
- (void)SocketManagerStatusChanged:(SocketStatus)status;

- (void)SocketManagerDidReceiveMessage:(NSString *)msg;

- (void)SocketManagerDidReceiveDict:(NSDictionary *)dict;

@end

@interface XMSocketManager : NSObject
@property (nonatomic, assign) SocketStatus socketStatus;
@property (nonatomic, weak) id<XMSocketManagerDelegate>delegate;
+ (instancetype)share;
//- (void)addSocketDelegate:(id<XMSocketManagerDelegate>)delegate;
//- (void)removeSocketDelegate:(id<XMSocketManagerDelegate>)delegate;
- (BOOL)connect;
- (void)disconnect;
- (void)sendMessage:(NSString *)message;
- (void)sendDict:(NSDictionary *)dict;
@end
