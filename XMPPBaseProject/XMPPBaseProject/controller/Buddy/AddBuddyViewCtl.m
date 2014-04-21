//
//  AddBuddyViewCtl.m
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "AddBuddyViewCtl.h"
#import "XMPPHelper.h"

@interface AddBuddyViewCtl ()

@end

@implementation AddBuddyViewCtl

#pragma mark -life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewDidUnload {
    [self setBuddyNameField:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addBuddy:(id)sender {
    [XMPPHelper xmppBuddyAddWithUserName:self.buddyNameField.text];
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
