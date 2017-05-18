//
//  XMSocketManager.m
//  零派socket
//
//  Created by RenXiangDong on 2017/5/16.
//  Copyright © 2017年 RenXiangDong. All rights reserved.
//

#import "XMSocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <MJExtension/MJExtension.h>

#define kMessageTag 99
#define kDictionaryTag 110
#define kPingTag 120

static  NSString * Khost = @"10.75.45.27";
static const uint16_t Kport = 8282;
//static  NSString * Khost = @"10.75.115.209";
//static const uint16_t Kport = 5623;
@interface XMSocketManager()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_gcdSocket;
    NSTimer *_heartBeat;
    int _senBeatCount;//连续发送心跳包次数
    int _autoConnectCount;//断线重连次数，默认重连3次

}
@property (nonatomic, strong) NSMutableArray *delegates;
@end
@implementation XMSocketManager

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static XMSocketManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initSocket];
    });
    return instance;
}

- (void)initSocket {
    _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (BOOL)connect {
    _socketStatus = SocketStatus_connecting;
    return  [_gcdSocket connectToHost:Khost onPort:Kport error:nil];
}

- (void)disconnect {
    [_gcdSocket disconnect];
    self.socketStatus = SocketStatus_disconnectByUser;
}

- (void)sendMessage:(NSString *)message {
    NSData *data  = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdSocket writeData:data withTimeout:5 tag:kMessageTag];
}

- (void)sendDict:(NSDictionary *)dict {
    NSLog(@"%@",dict);
    NSData *data = [dict mj_JSONData];
    [_gcdSocket writeData:data withTimeout:-1 tag:kDictionaryTag];
}
/* 远程拉取消息 */
- (void)pullTheMsg {
    //监听读数据的代理  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [_gcdSocket readDataWithTimeout:-1 tag:110];
    
}

#pragma mark - 心跳包
/* 开启心跳包 */
- (void)initHeardBeat {
    [self destoryHeartBeat];
    if (_heartBeat == nil) {
        _heartBeat = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(heardBeatSendMessage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_heartBeat forMode:NSRunLoopCommonModes];
    }
    [_heartBeat fire];
}
/* 发送心跳包 */
- (void)heardBeatSendMessage {
    _senBeatCount ++;
    if (_senBeatCount > 3) {//大于三次为断开连接
        _socketStatus = SocketStatus_disconnect;
        [self destoryHeartBeat];
    } else {
        [self sendMessage:@"ping"];
    }
}

- (void)destoryHeartBeat {
    if (_heartBeat) {
        [_heartBeat invalidate];
        _heartBeat = nil;
    }
}
#pragma mark 代理
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"主机连接成功");
    self.socketStatus = SocketStatus_connect;
    [self pullTheMsg];
    [self initHeardBeat];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"断开连接");
    _senBeatCount = 0;
    if (self.socketStatus == SocketStatus_disconnectByUser) {
        return;
    }
    self.socketStatus = SocketStatus_disconnect;
    if (_autoConnectCount != 0) {
        [self connect];
        NSLog(@"-------------第%d次重连--------------",_autoConnectCount);
        _autoConnectCount -- ;
    } else {
         NSLog(@"----------------重连次数已用完------------------");
    }
}

- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"写入成功");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case kMessageTag: {
            NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"收到消息：%@",msg);
            if ([self.delegate respondsToSelector:@selector(SocketManagerDidReceiveMessage:)]) {
                [self.delegate SocketManagerDidReceiveMessage:msg];
            }
        }
            break;
        case kDictionaryTag: {
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"收到json消息：%@",dict);
            if (error) {
                break;
            }
            if ([self.delegate respondsToSelector:@selector(SocketManagerDidReceiveDict:)]) {
                [self.delegate SocketManagerDidReceiveDict:dict];
            }
        }
            break;
        case kPingTag:
            
            break;
        default:
            break;
    }   
    [self pullTheMsg];
}

#pragma mark - getter & setter
- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (void)setSocketStatus:(SocketStatus)socketStatus {
    if (_socketStatus == SocketStatus_disconnectByUser && socketStatus == SocketStatus_disconnect) {
        return;
    }
    _socketStatus = socketStatus;
    if ([self.delegate respondsToSelector:@selector(SocketManagerStatusChanged:)]) {
        [self.delegate SocketManagerStatusChanged:socketStatus];
    }
}

@end
