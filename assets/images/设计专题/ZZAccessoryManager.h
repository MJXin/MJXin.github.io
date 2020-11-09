//
//  ZZAccessoryManager.h
//  HoverCamera2
//
//  Created by Ma Jiaxin on 2020/2/21.
//  Copyright © 2020 Zerozero. All rights reserved.
//
#import <Foundation/Foundation.h>
@class EAAccessory;
@class USBCommandToHover;
@class MEDIASERVERCommandToMediaServer;
@class MEDIASERVERCommandToFpv;
@class USBAckFromHover;
@class MEDIASERVERCommandToMediaServerAck;
@class MEDIASERVERDataStream;

extern NSString *ZZAccessoryManagerConnectStatusDidUpdate;

/** 目前遥控器支持的最大写入速率， 不建议任何写入程序快与此值。
 * 内部做了限制，再快只会导致队列堆积
 */
extern NSTimeInterval const RemoteControlWriteInterval;

extern NSString * const ZZRCCommonProtocol;
extern NSString * const ZZRCVideoProtocol;
extern NSString * const ZZRCFileProtocol;

typedef void (^DidReceivedDataBlock)(NSData *);
typedef void (^DidParsedAckFromHoverBlock)(USBAckFromHover *);
typedef void (^DidParsedAckFromRC)(NSDictionary *);
typedef void (^DidParsedAckFromMediaServerBlock)(MEDIASERVERCommandToMediaServerAck *);
typedef void (^DidParsedDataStreamBlock)(MEDIASERVERDataStream *);
typedef void (^DidParsedVideoFrame)(NSData *);


typedef NS_ENUM(NSUInteger, USBConnectStatus) {
  CONNECTED = 1000,             // 已连接
  ATTACHED = 1001,              // Usb插入遥控器
  DETACHED = 1002,              // Usb拔离
  PERMISSION_DENIED = 1003      // 没权限
};

/**
 * 遥控器的外设类
 * 类自身 ：主要管理设备的连接与失连状态
 * 类子对象：拥有三个 EASessionController， 用于管理三个通道
 * 函数： 主要对外提供连接状态变更以及三个 EASessionController 的封装函数
 * （ps. 为什么不暴露三个 EASessionController 直接给外界调用，而要繁琐的封装起来？
 *  1.EASessionController 与 Accessory 对象以及连接状态直接相关， 每次重连 => Accessory 不是同一个对象 => EASession 需要重新创建 => EASessionController 回调需要重新监听。 如果暴露给外界（现在有多个外部调用）需要都判断连接状态，并重新关联 EASessionController
 
 *  2.EASessionController 的 - openSession 及 - closeSession 实际不与连接状态绑定。 外界使用时，openSession 后，即使断线 open 的状态也不会因此 close。（例如，预览流 View “需要显示” “实际能否显示” 其实是解耦的：
 *                           * 需要显示意味着即使收不到数据，但需要用数据， 所以之后若是连上需要立马展现出来。（所以若外界 “要用数据”， 即使断线，重连后得重新 openSession）
 *                           * 而断连与否，与预览流此时是否需要解析数据无关 （若外界“不用”数据， 即使连着， session 也是 close 状态）
 *                        ）
 *  但因为 EASessionController 会由于断连重新创建，所以他本身无法记录外界是否需要使用。 需要由 Manager 记录这个状态，在重连生成了新的 EASessionController 后依据状态做恢复。
 *  这样外界也无需监听连接状态， 不用先判断是否连接再调用 openSession
 *  （为什么不让 EASessionController 做？，因为 EASessionController 没有连接状态信息，只提供控制 sessionf函数）
 * ）
 *
 * 3. 分发消息
 */
@interface ZZAccessoryManager : NSObject
@property (readonly, nonatomic, assign) USBConnectStatus connectStatus;
@property (readonly, nonatomic, strong) EAAccessory *currentRCAccerrory;

+ (instancetype)shareManager;

- (void)start;
- (void)stop;
#pragma mark - Write
/**
 * 写指令 USBCommandToHover
 */
- (void)writeHoverCommand:(USBCommandToHover *)command;

/**
 * 写指令 RCMsg
 */
- (void)writeRCCommand:(NSDictionary *)command;

/**
 * 写指令 MEDIASERVERCommand
 */
- (void)writeMediaServerCommand:(MEDIASERVERCommandToMediaServer *)command;

/**
 * 写指令 MEDIASERVERCommandToFpv
 */
- (void)writeFpvCommand:(MEDIASERVERCommandToFpv *)command;

/**
 * 写指令（原始数据）
 */
- (void)writeData:(NSData *)data;


#pragma mark - Receive

/**
 * 添加解析 CE ACK 回调（记得remove),返回值是对象 ID
 * common 通道
 */
- (NSString *)addParsedAckFromHoverBlock:(DidParsedAckFromHoverBlock)block;

/**
 * 移除解析 CE ACK 后的回调
 * common 通道
 */
- (void)removeParsedAckFromHoverBlock:(NSString *)blockID;

/**
 * 添加解析 RC ACK 回调（记得remove),返回值是对象 ID
 * common 通道
 */
- (NSString *)addParsedAckFromRCBlock:(DidParsedAckFromRC)block;

/**
 * 移除解析 RC ACK 后回调
 * common 通道
 */
- (void)removeParsedAckFromRCBlock:(NSString *)blockID;


/**
 * 添加解析 MediaServer ACK 回调（记得remove),返回值是对象 ID
 * command 通道
 */
- (NSString *)addParsedAckFromMediaServerBlock:(DidParsedAckFromMediaServerBlock)block;

/**
 * 移除解析 MediaServer ACK 后回调
 * command 通道
 */
- (void)removeParsedAckFromMediaServerBlock:(NSString *)blockID;

/**
 * 添加解析 视频帧 后的回调
 * video 通道
 */
- (NSString *)addParsedVideoFrameBlock:(DidParsedVideoFrame)block;

/**
 * 移除解析 视频帧 后的回调
 * video 通道
 */
- (void)removeParsedVideoFrameBlock:(NSString *)blockID;

/**
 * 添加解析 Data Stream 后的回调（记得remove),返回值是对象 ID
 * file 通道
 */
- (NSString *)addParsedDataStreamBlock:(DidParsedDataStreamBlock)block;

/**
 * 移除解析 Data Stream 后的回调
 * file 通道
 */
- (void)removeParsedDataStreamBlock:(NSString *)blockID;



#pragma mark - Debug
// 调试用， 原则上上层无需关心从哪个通道收到了啥，怎么解析

//MARK: common 通道
/**
 * 添加收到 common 通道*原始数据* 后的回调（记得remove),返回值是对象 ID
 * Debug 用
 * common 通道
 */
- (NSString *)addReceivedCommandDataBlock:(DidReceivedDataBlock)didReadedNewDataBlock;
/**
 * 移除收到 common 通道*原始数据*后
 * Debug 用
 * common 通道
 */
- (void)removeReceivedCommandDataBlock:(NSString *)blockID;

//MARK: video 通道

/**
 * 添加收到收到 video 通道 *原始数据* 后的回调（记得remove),返回值是对象 ID
 * Debug 用
 * video 通道
 */
- (NSString *)addReceivedVideoDataBlock:(DidReceivedDataBlock)didReadedNewDataBlock;
/**
 * 移除收到 video 通道 *原始数据* 后
 * Debug 用
 * video 通道
 */
- (void)removeReceivedVideoDataBlock:(NSString *)blockID;


@end
