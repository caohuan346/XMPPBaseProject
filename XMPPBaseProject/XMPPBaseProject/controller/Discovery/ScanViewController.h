//
//  ScanViewController.h
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-23.
//  Copyright (c) 2014年 caohuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Decoder.h>

@interface ScanViewController : UIViewController<UIAlertViewDelegate, DecoderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>{
    UIImageView *readLineView;
    BOOL is_Anmotion;
    AVCaptureSession *_captureSession;
    Decoder *decoder;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, assign) BOOL stopScan;

- (IBAction)choosePhoto:(id)sender;
- (void)reScan;

@end
