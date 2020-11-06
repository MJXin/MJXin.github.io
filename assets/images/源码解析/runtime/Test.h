//
//  Test.h
//  Test
//
//  Created by Ma Jiaxin on 2020/8/26.
//  Copyright © 2020 Hangzhou Zero Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Test : NSObject {
    NSNumber *testProperty1;
    NSString *testProperty2;
    Test *testProperty3;
}
- (void)testFunction;
@end

NS_ASSUME_NONNULL_END
