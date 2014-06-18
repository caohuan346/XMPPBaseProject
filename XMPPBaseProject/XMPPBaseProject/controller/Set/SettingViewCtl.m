//
//  SettingViewCtl.m
//  BaseProject
//
//  Created by caohuan on 13-11-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SettingViewCtl.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SettingViewCtl ()

@end

@implementation SettingViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginOut:(id)sender {
    
//    UIWindow *window = SharedAppDelegate.window;
//    UIViewController *vc = window.rootViewController;
//    UIViewController *initialVC = vc.storyboard.instantiateInitialViewController;
//    window.rootViewController = initialVC;
    
    //首先到登陆页面
    LoginViewController *loginViewController = [[LoginViewController alloc]init];
    SharedAppDelegate.window.rootViewController = loginViewController;
    
//    [SharedAppDelegate logout];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
}


@end
