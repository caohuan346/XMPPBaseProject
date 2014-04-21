//
//  SettingViewCtl.m
//  BaseProject
//
//  Created by caohuan on 13-11-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SettingViewCtl.h"
#import "AppDelegate.h"

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
    [SharedAppDelegate logout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
