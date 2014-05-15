//
//  XMPPBaseProjectTests.m
//  XMPPBaseProjectTests
//
//  Created by caohuan on 14-4-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"

@interface XMPPBaseProjectTests : XCTestCase

@end

@implementation XMPPBaseProjectTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
////    XCTAssertNil(<#a1#>, <#format...#>)
//    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}
- (void)testExample1
{
    NSArray *array;
    NSArray *array2;
    XCTAssertEqualObjects(array, array2, @"Should have returned the expected string.");
}

@end
