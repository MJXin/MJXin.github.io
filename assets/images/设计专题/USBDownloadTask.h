//
//  USBDownloadTask.h
//  HoverCamera2
//
//  Created by Ma Jiaxin on 2020/4/16.
//  Copyright © 2020 Zerozero. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, USBMediaDownloadTaskError) {
    USBMediaDownloadTaskErrorCancel,
    USBMediaDownloadTaskErrorTimeout,
};

@class MEDIASERVERCommandToFpv;
@class MEDIASERVERDataStream;
NS_ASSUME_NONNULL_BEGIN

typedef void (^TaskUpdateProgressBlock)(NSUInteger, NSUInteger);
typedef void (^TaskCompleteBlock)(NSString *);
typedef void (^TaskFailBlock)(USBMediaDownloadTaskError);

@interface RequestingInfo: NSObject
@property(nonatomic, readonly, strong) MEDIASERVERCommandToFpv *command;
@property(nonatomic, assign) NSTimeInterval countDown;
@property(nonatomic, assign) NSUInteger remainLength;
@end

@interface ReceivedInfo: NSObject
@property(nonatomic, assign) NSUInteger seqNo;
@property(nonatomic, strong) NSData *data;
@property(nonatomic, assign) NSUInteger rangeStart;
@property(nonatomic, assign) NSUInteger rangeEnd;
@end


/**
 * USB 下载基类，本身无法完成下载（因为没有构造具体的 MEDIASERVERCommandToFpv）
 * 需要子类覆写 downloadCommandWithRangeStart 函数， 构造出子类对应下载指令。 覆写 streamInfoFromDataStream 函数， 将收到的数据转换为通用数据。
 */
@interface USBDownloadTask : NSObject
@property (nonatomic, strong) TaskUpdateProgressBlock updateProgress;
@property (nonatomic, strong) TaskCompleteBlock downloadCompleted;
@property (nonatomic, strong) TaskFailBlock downloadFailed;
@property (nonatomic, assign, readonly) NSString * taskID;
@property (nonatomic, assign, readonly) NSUInteger size;
@property (nonatomic, strong, readonly) NSString * path;
+ (void)setMaxMBs:(double)MBs;
- (instancetype)initWithTaskID:(NSString *)taskID size:(NSUInteger)size targetPath:(NSString *)path;
/** 生成请求指令， 需要子类覆写*/
- (MEDIASERVERCommandToFpv *)downloadCommandWithRangeStart:(NSUInteger)rangeStart end:(NSUInteger)rangeEnd;
/** 收到的数据转换为通用的信息， 需要子类覆写*/
- (ReceivedInfo *) streamInfoFromDataStream:(MEDIASERVERDataStream *)stream;
- (void)start;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
