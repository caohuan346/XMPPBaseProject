//
//  ScanViewController.m
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-23.
//  Copyright (c) 2014年 caohuan. All rights reserved.
//

#import "ScanViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QRCodeReader.h>
#import <TwoDDecoderResult.h>
#import <ZXingWidgetController.h>
#import <MultiFormatOneDReader.h>
//#import "UINavigationItem+NavButton.h"
//#import "APPOAController.h"
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//判断是否是iPhone5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

@interface ScanViewController ()

@end

@implementation ScanViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark - UIView Methods -
- (void)loadView{
    
    //初始化View
    UIView *aView = [[UIView alloc] init];
    aView.frame = CGRectMake(0.0, 0.0, 320.0, 416.0+ (iPhone5?88.0:0.0));
    aView.backgroundColor = [UIColor clearColor];
    self.view = aView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.stopScan) {
        [self reScan];
    }else{
        [self pauseScan];
        [_captureSession stopRunning];
        self.stopScan = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reScan) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.title = @"快扫";
    decoder = [[Decoder alloc] init];
    _captureSession = [[AVCaptureSession alloc] init];
    [self initCapture];
    [self customOverlayView];
    
    CGRect  rect = CGRectMake(60.0, 120.0, 200.0, 2.0);
    readLineView = [[UIImageView alloc] initWithFrame:rect];
    [self.view addSubview:readLineView];
    readLineView.backgroundColor = [UIColor greenColor];
    
    [self loopDrawLine];
    
//    [self.navigationItem modfyNavLeftButton:@"广场" action:@selector(backList) target:self];
//    [self.navigationItem modfyNavRightButton:@"相册选择" secondString:nil action:@selector(pressPhotoLibraryButton:) target:self];
}
-(void)backList
{
    decoder.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
}

//暂停扫描动画
- (void)pauseScan
{
    CFTimeInterval pausedTime = [readLineView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    readLineView.layer.speed= 0.0;
    readLineView.layer.timeOffset= pausedTime;
}

//继续扫描动画
- (void)resumeScan
{
    CFTimeInterval pausedTime = [readLineView.layer timeOffset];
    readLineView.layer.speed= 1.0;
    readLineView.layer.timeOffset= 0.0;
    readLineView.layer.beginTime= 0.0;
    CFTimeInterval timeSincePause = [readLineView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    readLineView.layer.beginTime= timeSincePause;
}

-(void)loopDrawLine
{
    NSLog(@"%@", readLineView.layer.animationKeys);
    
    [readLineView.layer removeAllAnimations];
    CABasicAnimation*translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.fromValue= [NSValue valueWithCGPoint:CGPointMake(160.0f, 120.0)];
    translation.toValue= [NSValue valueWithCGPoint:CGPointMake(160.0f, 320.0)];
    translation.duration= 4.0f;
    translation.repeatCount= HUGE_VALF;
    readLineView.layer.speed= 1.0;
    [readLineView.layer addAnimation:translation forKey:@"translation"];
    
}
#pragma mark - 自定义OverlayView -
- (void )customOverlayView{
    OverlayView *aView = [[OverlayView alloc] initWithFrame:self.view.frame cancelEnabled:NO oneDMode:NO showLicense:NO];
    aView.cropRect = CGRectMake(60.0, 120.0, 200.0, 200.0);
    aView.displayedMessage = @"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [self.view addSubview:aView];
}
#pragma mark - 选择相册图片 -
- (void)pressPhotoLibraryButton:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        self.isScanning = NO;
        [self pauseScan];
        [_captureSession stopRunning];
    }];
}
#pragma mark - 初始化相机 -
- (void)initCapture{
    AVCaptureDevice* inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    [_captureSession addInput:captureInput];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    NSString* key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [_captureSession addOutput:captureOutput];
    
    NSString* preset = 0;
    if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
        [UIScreen mainScreen].scale > 1 &&
        [inputDevice
         supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
            // NSLog(@"960");
            preset = AVCaptureSessionPresetiFrame960x540;
        }
    if (!preset) {
        // NSLog(@"MED");
        preset = AVCaptureSessionPresetMedium;
    }
    _captureSession.sessionPreset = preset;
    
    _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    
    _captureVideoPreviewLayer.frame = self.view.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer: _captureVideoPreviewLayer];
    
    self.isScanning = YES;
    [_captureSession startRunning];
    
}

#pragma mark - 选择相册图片 -
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    // Create and return an image object representing the specified Quartz image
    
    UIImage *image = [[UIImage alloc] initWithCGImage:cgImage scale:(CGFloat)1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}
#pragma mark - 解析图片中的二维码 -
- (void)decodeImage:(UIImage *)image
{
    //    Y_NSLOG_METHOD_NAME;
    MultiFormatOneDReader *oneReaders = [[MultiFormatOneDReader alloc]init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc] initWithObjects:oneReaders, qrcodeReader, nil];
    decoder.delegate = self;
    decoder.readers = readers;
    [decoder decodeImage:image];
}

#pragma mark - DecoderDelegate 代理方法 -
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result
{
    
    //    Y_NSLOG_METHOD_NAME;
    self.isScanning = YES;
    [_captureSession stopRunning];
    [self pauseScan];
    //判断是否包含 头'http:'
    NSString *regex_http = @"http+:[^\\s]*";
    NSString *regex_https = @"https+:[^\\s]*";
    NSPredicate *predicate_http = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex_http];
    NSPredicate *predicate_https = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex_https];
    
    if ([predicate_http evaluateWithObject:result.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否打开此链接" message:result.text delegate:self cancelButtonTitle:nil otherButtonTitles:@"打开链接", @"复制内容", nil];
        alertView.tag = 1;
        [alertView show];
    }else if([predicate_https evaluateWithObject:result.text]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否打开此链接" message:result.text delegate:self cancelButtonTitle:nil otherButtonTitles:@"打开链接", @"复制内容", nil];
        alertView.tag = 1;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否网页搜索" message:result.text delegate:self cancelButtonTitle:nil otherButtonTitles:@"进入搜索", @"复制内容", nil];
        alertView.tag = 2;
        [alertView show];
    }
}
- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason
{
    //    Y_NSLOG_METHOD_NAME;
    if (!self.isScanning) {
        self.isScanning = YES;
        [_captureSession stopRunning];
        [self pauseScan];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有发现二维码" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = 3;
        alertView.delegate = self;
        [alertView show];
    }
}
#pragma mark - UIAlertViewDelegate 代理方法 -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == 3) {
        [self reScan];
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            
            NSString *urlString = nil;
            if (alertView.tag == 2) {
                NSString *searchMessage = [NSString stringWithFormat:@"http://www.baidu.com/s?wd=%@&rsv_bp=0&rsv_spt=3&rsv_sug3=2&rsv_sug=0&rsv_sug4=235&rsv_sug1=1&inputT=731", alertView.message];
                urlString = searchMessage;
            }else{
                urlString = alertView.message;
            }
            
            /*
            APPOAController *browser=[[[APPOAController alloc] initWithNibName:@"APPOAController" bundle:Nil] autorelease];
            browser.isBroswer=YES;
            browser.urlString=urlString;
            browser.hidesBottomBarWhenPushed=YES;
            browser.scanViewController = self;
            [self.navigationController pushViewController:browser animated:YES];
             */
        }
            break;
        case 1:
        {
            self.isScanning = YES;
            //把字符串放置到剪贴板上：
            UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
            pasteboard.string = alertView.message;
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
    
    
}

- (void)reScan{
    
    self.isScanning = YES;
    [_captureSession startRunning];
    [self loopDrawLine];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate 代理方法 -

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //    Y_NSLOG_METHOD_NAME;
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self decodeImage:image];
}


#pragma mark - UIImagePickerControllerDelegate 相册选择代理方法 -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.stopScan = YES;
    self.isScanning = NO;
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self dismissViewControllerAnimated:YES completion:^{
        [self decodeImage:image];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.stopScan = NO;
    self.isScanning = YES;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
