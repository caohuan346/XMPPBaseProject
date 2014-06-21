//  Globals.m
//  EduSun
//
//  Created by yisi on 13-4-21.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//
//

#import "Globals.h"
#import "PathService.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Globals

- (id)init {
	if ((self = [super init])) {
        
        self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];
        self.xmppServerPort = @"5222";
        /*
		self.unreadMessageNumbers = 0;
        self.unreadClassZoneNumbers = 0;
        self.unreadOperateNumbers = 0;
        */
        
        //init info from personl plist
        NSString *personalPlistPath = [PathService pathOfConfigFileForCurrentUser:self.userId];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithContentsOfFile:personalPlistPath];
        if (infoDic) {
            self.soundOn = [[infoDic objectForKey:@"soundOn"] boolValue];
            self.vibrateOn = [[infoDic objectForKey:@"vibrateOn"] boolValue];
        }else{
            infoDic = [NSMutableDictionary dictionary];
            [infoDic setObject:[NSString stringWithFormat:@"%d",YES] forKey:@"soundOn"];
            [infoDic setObject:[NSString stringWithFormat:@"%d",YES] forKey:@"vibrateOn"];
            [infoDic writeToFile:personalPlistPath atomically:YES];
        }
	}
	return self;
}

- (void)clearWhenLogOut{
    self.loginState = FALSE;
    self.lastDBUpdateTime = -1;
    /*
    self.unreadMessageNumbers = 0;
    self.unreadOperateNumbers = 0;
    self.unreadClassZoneNumbers = 0;
     */
}

/*
-(void) setUnreadMessageNumbers:(NSInteger) unreadMessageNumbers{
    self.unreadMessageNumbers = _unreadMessageNumbers;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessageNumbers + self.unreadOperateNumbers + self.unreadClassZoneNumbers];
    //发出未读消息修改通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_UNREADMESSAGENUMBERCHANGE object:nil userInfo:nil];
}

-(void) setUnreadOperateNumbers:(NSInteger) unreadOperateNumbers{
    self.unreadOperateNumbers = unreadOperateNumbers;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.unreadMessageNumbers + unreadOperateNumbers + self.unreadClassZoneNumbers];
}

-(void) setUnreadClassZoneNumbers:(NSInteger) unreadClassZoneNumbers{
    self.unreadClassZoneNumbers = unreadClassZoneNumbers;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.unreadMessageNumbers + self.unreadOperateNumbers + unreadClassZoneNumbers];
}
*/

-(NSString *)fileServerUrl{
    if ([self.fileServerIP  length] > 0 && [self.fileServerPort length] > 0) {
        return [NSString stringWithFormat:@"http://%@:%@/upload/UploadServlet",self.fileServerIP,self.fileServerPort];
    }
    return nil;
}

#pragma mark - sound play
- (void)globalSystemSoundPlay
{
    _currentInterval = [[NSDate date]timeIntervalSinceReferenceDate];
    if ((_currentInterval - _previousInterval) > 0.5) {
        //发出消息提示音
        if (_soundOn || _vibrateOn) {
            _previousInterval = _currentInterval;
        }
        if (_soundOn) {
            @autoreleasepool{
                SystemSoundID soundID;
                //调用NSBundle类的方法mainBundle返回一个NSBundle对象，该对象对应于当前程序可执行二进制文件所属的目录
                NSString *soundFile = [[NSBundle mainBundle] pathForResource:kMessageSoundName ofType:@"caf"];
                //一个指向文件位置的CFURLRef对象和一个指向要设置的SystemSoundID变量的指针
                AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundFile], &soundID);
                AudioServicesPlaySystemSound(soundID);
            }
        }
        //震动提示
        if (_vibrateOn) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }else {
        if (_soundOn || _vibrateOn) {
            _previousInterval = _currentInterval;
        }
    }
}

#pragma mark - 
-(void)globalInfoPersist{
    NSString *personalPlistPath = [PathService pathOfConfigFileForCurrentUser:self.userId];
    BOOL isDirectory = TRUE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:personalPlistPath isDirectory:&isDirectory]) {
        
    }
}

@end
