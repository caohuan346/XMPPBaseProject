//
//  ChatViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User,FaceToolBar,AccessoryView;
@protocol FaceToolBarDelegate,AccessoryViewDelegate;
@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,  XMPPMessageDelegate,FaceToolBarDelegate,AccessoryViewDelegate>{
    AccessoryView *accessoryView;
}

@property(strong,nonatomic) User *chatTargetUser;

@property (weak, nonatomic) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet FaceToolBar *chatToolBar;

@end