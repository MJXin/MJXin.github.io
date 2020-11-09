//
//  USBDownloadTask.m
//  HoverCamera2
//
//  Created by Ma Jiaxin on 2020/4/16.
//  Copyright © 2020 Zerozero. All rights reserved.
//

#import "USBDownloadTask.h"
#import "ZZAccessoryManager.h"
#import "MediaServer.pbobjc.h"
static uint32_t SeqNo = xxx;
/**
 指令请求间隔
 ps. 不能超过遥控器写入指令的频次要求，目前最低 14ms，建议不低于 20ms，参考 ZZAccessoryManager
 并且考虑传输延迟和 乘 RequestBufferSize 后的带宽上限， 不是越小越好
*/
const NSTimeInterval RequestInterval = xxx;
/**
 单个请求超时触发重传的间隔
 ps. 这个值越大，累计的请求数理论最大值越高， 累计的接收缓存理论最大值越高，内存占用理论最大值越高
 */
const NSTimeInterval RetryInterval = xxx;

/**
 进度回调间隔
 */
const NSTimeInterval ProgressInterval = 250 / 1000.0;
/**
 最大请求数 （目前没有使用需求， 用上面两个值控制）
 超过 RetryInterval / RequestInterval 后意义不大，因为开始重传了
 */
const NSUInteger MaxRequestCount = xxx;
/**
 最大重传数
 */
const NSUInteger MaxRetryCount = xxx;
/** 最大缓存数 （目前没有使用需求， 用上面两个值控制）
 一个请求有多个回调， 要大于请求数
 飞机现在一包上限 2k（2020/3）, 可以算出最大占用内存
*/
const NSUInteger MaxReceivedCount = xxx;
// 当前遥控器每毫秒理论带宽 （Mbp）
double MBs = xxx;
// 每次请求的包大小 B, （当前用 80% 带宽的速度拿）
NSUInteger RequestBufferSize = xxxxxx;

@interface RequestingInfo()
@property(nonatomic, strong)NSMutableSet *receivedRangeStart;
@property(nonatomic, assign)NSUInteger rangeEnd;
@property(nonatomic, assign)NSUInteger retryCount;
@property(nonatomic, assign)NSUInteger dataLength;
@end
@implementation RequestingInfo

- (uint32_t)seqNo {return self.command.seqNo;}
- (void)reset {
  _countDown = 0;
  _remainLength = _dataLength;
  _retryCount += 1;
  [_receivedRangeStart removeAllObjects];
}

- (instancetype)initWithCommand:(MEDIASERVERCommandToFpv *)command rangeStart:(NSUInteger)start end:(NSUInteger)end {
  if(self = [super init]) {
    _command = command;
    _countDown = 0;
    _dataLength = end - start;
    _remainLength = _dataLength;
    _rangeEnd = end;
    _receivedRangeStart = [NSMutableSet set];
    _retryCount = 0;
  }
  return self;
}
@end

@implementation ReceivedInfo

@end

@interface USBDownloadTask()
@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, assign) NSTimeInterval progressCountDown;
@property (nonatomic, assign) NSUInteger currentFileIndex;
@property (nonatomic, assign) NSUInteger currentRequestIndex;
@property (nonatomic, strong) NSOutputStream *fileStream;
@property (nonatomic, strong) NSString *registedDataStreamBlock;
@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) dispatch_queue_t requestQueue;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
/** 重传数组，内容为 seqNo*/
@property (nonatomic, strong) NSMutableArray<NSNumber *> *retryCommands;
/** 请求中的指令， key 为 seqNo*/
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, RequestingInfo *> *requestingCommands;
/** 接收到的数据， key 为 seqNo*/
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSData *> *writeCache;
@end

@implementation USBDownloadTask
/** 请求指令， 需要子类覆写*/
- (MEDIASERVERCommandToFpv *)downloadCommandWithRangeStart:(NSUInteger)rangeStart end:(NSUInteger)rangeEnd {
  MEDIASERVERCommandToFpv *fpv = [MEDIASERVERCommandToFpv new];
  fpv.seqNo = SeqNo++;
  return fpv;
}
/** 收到的数据转换为通用的信息， 需要子类覆写*/
- (ReceivedInfo *) streamInfoFromDataStream: (MEDIASERVERDataStream *)stream {
  return [ReceivedInfo new];
}

- (instancetype)initWithTaskID:(NSString *)taskID size:(NSUInteger)size targetPath:(NSString *)path {
  if(self = [super init]) {
    _size = size;
    _path = path;
    _taskID = taskID;
    self.currentFileIndex = 0;
    self.isCancel = NO;
    self.isStart = NO;
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.path append:YES];
    const char * _Nullable requestQueueName = [[@"USB_DOWNLOAD_REQUEST_" stringByAppendingString:self.taskID] cStringUsingEncoding:kCFStringEncodingASCII];
    self.requestQueue = dispatch_queue_create(requestQueueName, DISPATCH_QUEUE_SERIAL);
    const char * _Nullable writeQueueName = [[@"USB_DOWNLOAD_WRITE_" stringByAppendingString:self.taskID] cStringUsingEncoding:kCFStringEncodingASCII];
    self.writeQueue = dispatch_queue_create(writeQueueName, DISPATCH_QUEUE_SERIAL);
    const char * _Nullable taskQueueName = [[@"USB_DOWNLOAD_TASK_" stringByAppendingString:self.taskID] cStringUsingEncoding:kCFStringEncodingASCII];
    self.taskQueue = dispatch_queue_create(taskQueueName, DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)dealloc {
  [self reset];
  [self.fileStream close];
  self.isCancel = YES;
  [[ZZAccessoryManager shareManager] removeParsedDataStreamBlock:self.registedDataStreamBlock];
}

- (void)start {
  if(self.isStart) return;
  self.isStart = YES;
  // 下面的数据每次都需要重置，不能移到 init 中
  if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
    [[NSFileManager defaultManager] createFileAtPath:self.path contents:nil attributes:nil];
  }
  self.currentFileIndex = [self getFileSize];
  if(self.currentFileIndex == self.size) {
    [self _downloadCompleted];
    return;
  }
  self.progressCountDown = 0;
  self.currentRequestIndex = self.currentFileIndex;
  self.retryCommands = [NSMutableArray array];
  self.writeCache = [NSMutableDictionary dictionary];
  self.requestingCommands = [NSMutableDictionary dictionary];
  [self.fileStream open];
  [self registerDataStream];
  [self startRequest];
}

- (void)pause {
  [self reset];
  // 不调用 [self.fileStream close]， 因为数据需要一些时间写入，直接调用会导致内存中数据写入失败，重开时进度回跳
  self.isStart = NO;
}

- (void)cancel {
  if(self.isCancel) return;
  [self pause];
  self.isCancel = YES;
  [self.fileStream close];
  if(self.downloadFailed) self.downloadFailed(USBMediaDownloadTaskErrorCancel);
}

- (void)timeout {
  if(self.isCancel) return;
  [self pause];
  self.isCancel = YES;
  [self.fileStream close];
  if(self.downloadFailed) self.downloadFailed(USBMediaDownloadTaskErrorTimeout);
}

#pragma mark - Private

- (void)registerDataStream {
  __weak typeof(self) weakSelf = self;
  // 监听 ZZAccessoryManager shareManager 的数据回调， 从中取出数据
  self.registedDataStreamBlock = [[ZZAccessoryManager shareManager] addParsedDataStreamBlock:^(MEDIASERVERDataStream *stream) {
    ReceivedInfo *receivedInfo = [weakSelf streamInfoFromDataStream:stream];
    //不是自己的请求的数据不要
    if(!weakSelf.requestingCommands[@(receivedInfo.seqNo)]) return;
    [weakSelf updateRequestingInfoFromReceiveInfo:receivedInfo];
    [weakSelf writeDataFromReceiveInfo:receivedInfo];
  }];
}

- (void)updateRequestingInfoFromReceiveInfo:(ReceivedInfo *)receivedInfo {
  __weak typeof(self) weakSelf = self;
  dispatch_async(weakSelf.taskQueue, ^{
    // 处理收到的数据
    RequestingInfo *requestingInfo = weakSelf.requestingCommands[@(receivedInfo.seqNo)];
    // 防止接收重复区间的数据（通常会发生在重传时，又收到了上一次的数据）
    if([requestingInfo.receivedRangeStart containsObject:@(receivedInfo.rangeStart)]) return;
    [requestingInfo.receivedRangeStart addObject:@(receivedInfo.rangeStart)];
    requestingInfo.remainLength -= receivedInfo.data.length;
    if(requestingInfo.remainLength <= 0) [weakSelf.requestingCommands removeObjectForKey:@(receivedInfo.seqNo)];
  });
}

- (void)writeDataFromReceiveInfo:(ReceivedInfo *)receivedInfo {
  __weak typeof(self) weakSelf = self;
  dispatch_async(weakSelf.writeQueue, ^{
    // 不需要的数据不放入缓存
    if(weakSelf.currentFileIndex > receivedInfo.rangeStart) return;
    // 已经收过的数据不要
    if(weakSelf.writeCache[@(receivedInfo.rangeStart)]) return;
    //将数据加入缓存
    weakSelf.writeCache[@(receivedInfo.rangeStart)] = receivedInfo.data;
    // 写文件
    [weakSelf writeToFile];
  });
}

- (void)startRequest {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.requestQueue, ^{
    //暂停， 取消，文件写完则直接结束
    while([weakSelf isRunable]) {
      // 处理进度回调
      [weakSelf updateProgressIfNeed];
      // 发指令
      [weakSelf sendCommand];
      [NSThread sleepForTimeInterval:RequestInterval];
    }
  });
}

- (void)updateProgressIfNeed {
  self.progressCountDown += RequestInterval;
  if(self.progressCountDown > ProgressInterval) {
    self.progressCountDown = 0;
    if(self.updateProgress) self.updateProgress(self.currentFileIndex, self.size);
  }
}

- (void)sendCommand {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.taskQueue, ^{
    // 处理重传
    [weakSelf checkRequestingCommand];
    // 所有需要的请求都发完了，不再继续发送（可能还有 command 在重传倒数中）
    if(weakSelf.currentRequestIndex >= weakSelf.size && weakSelf.retryCommands.count == 0) return;
    MEDIASERVERCommandToFpv *fpvCommand;
    // 优先生成重传指令
    if(weakSelf.retryCommands.count > 0){
      fpvCommand = [weakSelf generateRetryCommand];
    }
    // 如果无需重传，并且请求数已经超过最大数，那直接结束
    if(!fpvCommand && self.requestingCommands.count > MaxRequestCount) {
      return;
    }
    // 在没有无需重传， 并且MaxRequestCount还有容量的情况下， 请求新的指令
    if (!fpvCommand) {
      fpvCommand = [weakSelf generateNextCommand];
    }
    [[ZZAccessoryManager shareManager] writeFpvCommand:fpvCommand];
  });
}

- (MEDIASERVERCommandToFpv *)generateRetryCommand {
  MEDIASERVERCommandToFpv *command;
  while (!command && self.retryCommands.count > 0) {
    uint32_t seqNo = [self.retryCommands.firstObject unsignedIntValue];
    [self.retryCommands removeObjectAtIndex:0];
    if(self.requestingCommands[@(seqNo)] == nil) continue;
    RequestingInfo *info = self.requestingCommands[@(seqNo)];
    [info reset];
    [self checkTimeout:info];
    command = info.command;
  }
  return command;
}

- (MEDIASERVERCommandToFpv *)generateNextCommand {
  NSUInteger rangeStart = self.currentRequestIndex;
  NSUInteger rangeEnd = MIN(self.currentRequestIndex + RequestBufferSize, self.size);
  self.currentRequestIndex = rangeEnd;
  RequestingInfo *info = [[RequestingInfo alloc] initWithCommand:[self downloadCommandWithRangeStart:rangeStart end:rangeEnd] rangeStart:rangeStart end:rangeEnd];
  self.requestingCommands[@([info seqNo])] = info;
  return info.command;
}

- (void)checkTimeout:(RequestingInfo *)info {
  // 检查重传， 符合条件就发消息
  // ... 省略
   dispatch_async(dispatch_get_main_queue(), ^{
     [self timeout];
   });
}

- (void)checkRequestingCommand {
  [self.requestingCommands enumerateKeysAndObjectsUsingBlock: ^(NSNumber * _Nonnull key, RequestingInfo * _Nonnull obj, BOOL * _Nonnull stop) {
    obj.countDown += RequestInterval;
    if(obj.countDown > RetryInterval) [self.retryCommands addObject:key];
  }];
}

/**
 写入文件， 必须在写入队列中执行
 */
- (void)writeToFile {
  if(self.isCancel || !self) return;
  // 查找收到的数据中是否有当前位置的数据
  NSData *nextData = self.writeCache[@(self.currentFileIndex)];
  while(nextData && [self isRunable]) {
    if(self.isCancel || !self) return;
    // 将数据写入文件
    [self.fileStream write:nextData.bytes maxLength:nextData.length];
    // 从缓存中移除
    [self removeCache:@(self.currentFileIndex)];
    // 移动下标
    self.currentFileIndex += nextData.length;
    // 判断是否已经下载完毕
    if(self.currentFileIndex >= self.size) {
      // 下载完毕调用回调
      [self _downloadCompleted];
      return;
    } else {
      // 未下载完则继续写入下一个数据，直到找不到连续的下一个数据为止
      nextData = self.writeCache[@(self.currentFileIndex)];
    }
  }
}

- (void)removeCache:(NSNumber *)rangeStart {
  __weak typeof(self) weakSelf = self;
  dispatch_async(weakSelf.writeQueue, ^{
    [weakSelf.writeCache removeObjectForKey:rangeStart];
  });
}

- (void) reset {
  self.writeCache = nil;
  self.retryCommands = nil;
  self.requestingCommands = nil;
  self.progressCountDown = 0;
  [[ZZAccessoryManager shareManager] removeParsedDataStreamBlock:self.registedDataStreamBlock];
}

- (void)_downloadCompleted {
  self.isStart = NO;
  self.isCancel = NO;
  [self reset];
  [self.fileStream close];
  if(self.downloadCompleted) self.downloadCompleted(self.path);
}

- (BOOL)isRunable {
  return self.isStart && !self.isCancel && self.currentFileIndex < self.size;
}

- (NSUInteger)getFileSize {
  if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]) return 0;
  NSError *error;
  NSDictionary<NSFileAttributeKey, id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:&error];
  if(error) return 0;
  return [attributes[NSFileSize] unsignedLongLongValue];
}

@end

