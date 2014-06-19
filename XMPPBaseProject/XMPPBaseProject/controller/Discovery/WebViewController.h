//
//  WebViewController.h
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-24.
//  Copyright (c) 2014年 caohuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property(copy,nonatomic) NSString *urlStr;
@end
