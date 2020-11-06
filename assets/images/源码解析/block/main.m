//
//  main.m
//  BlockTest
//
//  Created by Ma Jiaxin on 2020/10/24.
//  Copyright © 2020 Hangzhou Zero Zero. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MyObject: NSObject {
    
}
@end
@implementation MyObject


@end
int globalInt = 200;
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        MyObject *myObj = [MyObject new];
        MyObject *myObj2 = [MyObject new];
        __block int mainInt = 0;
        void (^blockWithoutVar)(void) = ^{
            printf("blockWithoutVar \n");
        };
        
        void (^blockWithVar)(void) = ^{
            printf("myObj %s\n", [[myObj description] UTF8String]);
            printf("myObj2 %s\n", [[myObj2 description] UTF8String]);
            printf("mainInt %d\n", mainInt);
            printf("mainNum %d\n", globalInt);
        };
        mainInt = 5;
        globalInt = 4;
        
        blockWithoutVar();
        blockWithVar();
        NSLog(@"%@", blockWithoutVar);
        NSLog(@"%@", blockWithVar);
    }
    return 0;
}
