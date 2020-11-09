//
//  EASessionController.h
//  HoverCamera2
//
//  Created by Ma Jiaxin on 2020/2/15.
//  Copyright © 2020 Zerozero. All rights reserved.
//

#if HOVER_SUPPORT_USB_CONNECT == 1
#import "USBParserProtocol.h"
@import Foundation;
@import ExternalAccessory;

@interface EASessionController<__covariant PacketType>: NSObject<NSStreamDelegate>
typedef void (^DidReadedNewDataBlock)(NSData *);
typedef void (^DidParsedBlock)(PacketType);
- (instancetype)initWithAccessory:(EAAccessory *)accessory
                   protocolString:(NSString *)protocolString
                           parser:(id<USBParserProtocol>)parser;

- (BOOL)isSessionWorking;
- (BOOL)openSession;
- (void)closeSession;

- (void)write:(PacketType)packet;
- (void)writeData:(NSData *)data;
/**
 收到数据回调， 默认执行再 EASession 控制的内部线程中
 */
@property (nonatomic, strong) DidReadedNewDataBlock didReadedNewData;
@property (nonatomic, strong) DidParsedBlock didParsed;
@property (nonatomic, strong, readonly) EAAccessory *accessory;
@property (nonatomic, strong, readonly) NSString *protocolString;
@property (nonatomic, strong, readonly) dispatch_queue_t sessionQueue;
@end
#endif
