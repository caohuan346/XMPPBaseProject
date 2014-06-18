//
//  LoginViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COMScrollView;
@interface LoginViewController : UIViewController<XMPPServerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
//@property (retain, nonatomic) IBOutlet UITextField *serverTextField;


//login
- (IBAction)toLogin:(id)sender;

- (IBAction)toRegister:(id)sender;
@end
