//
//  BuddyViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPServer.h"

@interface BuddyViewController : UITableViewController<XMPPPresenceDelegate>
- (IBAction)addNewBuddy:(id)sender;

@end
