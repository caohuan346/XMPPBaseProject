//
//  AddBuddyViewCtl.h
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBuddyViewCtl : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *buddyNameField;

- (IBAction)addBuddy:(id)sender;

@end
