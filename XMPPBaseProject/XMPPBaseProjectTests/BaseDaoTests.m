//
//  BaseDaoTests.m
//  XMPPBaseProject
//
//  Created by hc on 14-7-5.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Conversation.h"
#import "BaseDao.h"

@interface BaseDaoTests : XCTestCase

@end

@implementation BaseDaoTests

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

- (void)testInsert{
    Conversation *model = [[Conversation alloc] init];
    model.senderId = @"10002";
    model.time = [NSDate date];
    model.msgContent = @"testMsg";
    model.unreadCount = 10;
    model.type = ConversationTypePersonalChat;
    model.detailType = MessageContentType_Text;
    
    NSLog(@"%p",[BaseDao sharedInstance]);
    BOOL flag = [[BaseDao sharedInstance] insertDBModel:model];
    
    XCTAssertEqual(flag, YES, @"插入成功");
}

- (void)testDelete{
    Conversation *model = [[Conversation alloc] init];
    model.oid = 1;
    BOOL flag = [[BaseDao sharedInstance] deleteDbModel:model];
    XCTAssertEqual(flag, YES, @"删除成功");
}

@end
