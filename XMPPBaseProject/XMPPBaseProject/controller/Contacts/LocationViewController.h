//
//  LocationViewController.h
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-24.
//  Copyright (c) 2014年 caohuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface LocationViewController : UIViewController<BMKMapViewDelegate>{
    IBOutlet BMKMapView* _mapView;
    IBOutlet UIButton* startBtn;
    IBOutlet UIButton* stopBtn;
    IBOutlet UIButton* followingBtn;
    IBOutlet UIButton* followHeadBtn;
}
-(IBAction)startLocation:(id)sender;
-(IBAction)stopLocation:(id)sender;
-(IBAction)startFollowing:(id)sender;
-(IBAction)startFollowHeading:(id)sender;

@end
