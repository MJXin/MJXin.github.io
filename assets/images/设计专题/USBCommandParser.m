//
//  USBCommandParser.m
//  HoverCamera2
//
//  Created by Ma Jiaxin on 2020/2/15.
//  Copyright © 2020 Zerozero. All rights reserved.
//

#import "USBCommandParser.h"
const UInt8 HeaderLength = 10;

@interface USBCommandParser()
@property(readonly, nonatomic, strong, nullable) USBCommandPacket *currentFrame;
@property(readonly, nonatomic, assign) USBCommandParserState state;
@property(readonly, nonatomic, assign) NSInteger remainPayloadToParse;
@property(nonatomic, assign) BOOL isInterrupt;
@property(nonatomic, assign) NSUInteger currentPacketIndex;
@property(nonatomic, assign) NSUInteger lastPacketIndex;
@end
@implementation USBCommandParser
+ (NSData *)objectToData:(USBCommandPacket *)packet {
  // 创建包头
  Byte header[HeaderLength];
  header[0] = USBCommandParserConstHeader1;
  header[1] = USBCommandParserConstHeader2;
  // 此处是根据协议创建包头，然后拼起来， 具体的协议内容略过
  // ... 最后是长度和校验码生成
  header[x] = (packet.length & 0x0FF);
  header[x] = ((packet.length >> 8) & 0x0FF);
  header[x] = (packet.checkSum & 0x0FF);
  header[x] = ((packet.checkSum >> 8) & 0x0FF);
  
  NSMutableData *data = [NSMutableData dataWithBytes:header length:HeaderLength];
  [data appendData:packet.payload];
  return data;
}

- (instancetype)init{
  if(self = [super init]){
    _state = USBCommandParserWaitingConstHeader1;
    _currentFrame = [USBCommandPacket new];
    _isInterrupt = NO;
    _remainPayloadToParse = 0;
    _currentPacketIndex = 0;
    _lastPacketIndex = -1;
  }
  return self;
}

- (void)interrupt {
  _isInterrupt = YES;
}

- (void)parse:(NSData *)data {
  _isInterrupt = NO;
  __weak typeof(self) weakSelf = self;
  [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
    NSInteger index = 0;
    while (index < byteRange.length && !weakSelf.isInterrupt) {
      if(_state == USBCommandParserWaitingPayload) {
        NSInteger length = MIN(_remainPayloadToParse, byteRange.length - index);
        [weakSelf appendPayload:&bytes[index] length:length];
        index += length;
      } else {
        [weakSelf parseByte:((uint8_t *)bytes)[index]];
        index++;
      }
    }
  }];
}

- (void)parseByte:(uint8_t)byte {
  switch (_state) {
    case USBCommandParserWaitingConstHeader1:
      if(byte == USBCommandParserConstHeader1) {
        _state = USBCommandParserWaitingConstHeader2;
      } else if(byte != 0x00) {
        [self reset];
      }
      // 遥控器会自动补一些 0，这些 0 自动忽略
      break;
    case USBCommandParserWaitingConstHeader2:
      if(byte == USBCommandParserConstHeader2) {
        _state = USBCommandParserWaitingMessageID1;
      } else {
        [self reset];
      }
      break;
    // 实现逻辑就是，收到一个字节，判断是不是符合协议的，如果是，将状态更新为等待下一个协议字段，如果不是，重置
    case xxx: {
      _state = xxx;
      _currentFrame.xxx = byte;
      break;
    }
    case xxx: {
      _state = xxx;
      _currentFrame.xxx = byte
      break;
    }
    // 有些数据字段几个协议才能表示， 这时候就要注意大小端问题
    case USBCommandParserWaitingLengthLSB: {
      _state = USBCommandParserWaitingLengthMSB;
      _currentFrame.length = byte;
      break;
    }
    case USBCommandParserWaitingLengthMSB: {
      _state = USBCommandParserWaitingCheckSumLSB;
      _currentFrame.length = _currentFrame.length + (byte << 8);
      _remainPayloadToParse = _currentFrame.length;
      break;
    }
    case USBCommandParserWaitingPayload: {
      [_currentFrame.payload appendBytes:&byte length:1];
      _remainPayloadToParse --;
      [self checkParseFinish];
      break;
    }
  }
}

- (void)appendPayload:(const void * _Nonnull)bytes length:(NSInteger)length {
  if(!_currentFrame.payload) {
    _currentFrame.payload = [NSMutableData dataWithBytes:bytes length:length];
  } else {
    [_currentFrame.payload appendBytes:bytes length:length];
  }
  _remainPayloadToParse -= length;
  [self checkParseFinish];
}

- (void)checkParseFinish {
  // 拼接 payload 后判断长度， 
  // 如果已经收到了完整长度，则做校验
}

- (void)reset {
  _state = USBCommandParserWaitingConstHeader1;
  _currentFrame = [USBCommandPacket new];
  _remainPayloadToParse = 0;
  _currentPacketIndex = 0;
  _lastPacketIndex = -1;
}
@end
