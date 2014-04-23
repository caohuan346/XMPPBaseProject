// -*- Mode: ObjC; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OverlayView.h"

static const CGFloat kPadding = 10;
static const CGFloat kLicenseButtonPadding = 10;

@interface OverlayView()
@property (nonatomic,assign) UIButton *cancelButton;
@property (nonatomic,assign) UIButton *licenseButton;
@property (nonatomic,retain) UILabel *instructionsLabel;
@end


@implementation OverlayView

@synthesize delegate, oneDMode;
@synthesize points = _points;
@synthesize cancelButton;
@synthesize licenseButton;
@synthesize cropRect;
@synthesize instructionsLabel;
@synthesize displayedMessage;
@synthesize cancelButtonTitle;
@synthesize cancelEnabled;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled {
    return [self initWithFrame:theFrame cancelEnabled:isCancelEnabled oneDMode:isOneDModeEnabled showLicense:YES];
}

- (id) initWithFrame:(CGRect)theFrame cancelEnabled:(BOOL)isCancelEnabled oneDMode:(BOOL)isOneDModeEnabled showLicense:(BOOL)showLicenseButton {
    self = [super initWithFrame:theFrame];
    if( self ) {
        
        CGFloat rectSize = self.frame.size.width - kPadding * 2;
        if (!oneDMode) {
            cropRect = CGRectMake(kPadding, (self.frame.size.height - rectSize) / 2, rectSize, rectSize);
        } else {
            CGFloat rectSize2 = self.frame.size.height - kPadding * 2;
            cropRect = CGRectMake(kPadding, kPadding, rectSize, rectSize2);
        }
        
        self.backgroundColor = [UIColor clearColor];
//        self.oneDMode = isOneDModeEnabled;
        
        if (showLicenseButton) {
            self.licenseButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            
            CGRect lbFrame = [licenseButton frame];
            lbFrame.origin.x = self.frame.size.width - licenseButton.frame.size.width - kLicenseButtonPadding;
            lbFrame.origin.y = self.frame.size.height - licenseButton.frame.size.height - kLicenseButtonPadding;
            [licenseButton setFrame:lbFrame];
            [licenseButton addTarget:self action:@selector(showLicenseAlert:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:licenseButton];
        }
        self.cancelEnabled = isCancelEnabled;
        
        if (self.cancelEnabled) {
            UIButton *butt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.cancelButton = butt;
            if ([self.cancelButtonTitle length] > 0 ) {
                [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
            } else {
                [cancelButton setTitle:NSLocalizedStringWithDefaultValue(@"OverlayView cancel button title", nil, [NSBundle mainBundle], @"Cancel", @"Cancel") forState:UIControlStateNormal];
            }
            [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
        }
    }
    return self;
}

- (void)cancel:(id)sender {
	// call delegate to cancel this scanner
	if (delegate != nil) {
		[delegate cancelled];
	}
}

- (void)showLicenseAlert:(id)sender {
    NSString *title =
    NSLocalizedStringWithDefaultValue(@"OverlayView license alert title", nil, [NSBundle mainBundle], @"License", @"License");
    
    NSString *message =
    NSLocalizedStringWithDefaultValue(@"OverlayView license alert message", nil, [NSBundle mainBundle], @"Scanning functionality provided by ZXing library, licensed under Apache 2.0 license.", @"Scanning functionality provided by ZXing library, licensed under Apache 2.0 license.");
    
    NSString *cancelTitle =
    NSLocalizedStringWithDefaultValue(@"OverlayView license alert cancel title", nil, [NSBundle mainBundle], @"OK", @"OK");
    
    NSString *viewTitle =
    NSLocalizedStringWithDefaultValue(@"OverlayView license alert view title", nil, [NSBundle mainBundle], @"View License", @"View License");
    
    UIAlertView *av =
    [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:viewTitle, nil];
    
    [av show];
    [self retain]; // For the delegate callback ...
    [av release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apache.org/licenses/LICENSE-2.0.html"]];
    }
    [self release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
	[_points release];
    [instructionsLabel release];
    [displayedMessage release];
    [cancelButtonTitle release],
	[super dealloc];
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context fillPath:(BOOL) fill{
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    
    if (fill) {
        CGContextSetFillColorWithColor(context, CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.5f));
        CGContextFillPath(context);
    }else{
        CGContextSetStrokeColorWithColor(context, CGColorCreateCopyWithAlpha([UIColor whiteColor].CGColor, 0.8f));
        CGContextSetFillColorWithColor(context, CGColorCreateCopyWithAlpha([UIColor whiteColor].CGColor, 0.8f));
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokePath(context);
    }
    
	
}
- (void)drawFocus:(CGRect) rect inContext:(CGContextRef)context{
    CGContextBeginPath(context);
    float width = rect.size.width/8.0f;
    float height = rect.size.height/8.0f;
    
    //左上
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + width, rect.origin.y);
    //右上
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width - width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + height);
    //左下
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + width, rect.origin.y + rect.size.height);
    //右下
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width - width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - height);
    
    CGContextSetStrokeColorWithColor(context, CGColorCreateCopyWithAlpha([UIColor greenColor].CGColor, 1.0f));
    CGContextSetFillColorWithColor(context, CGColorCreateCopyWithAlpha([UIColor greenColor].CGColor, 1.0f));
    CGContextSetLineWidth(context, 3.0f);
    CGContextStrokePath(context);
}

- (CGPoint)map:(CGPoint)point {
    CGPoint center;
    center.x = cropRect.size.width/2;
    center.y = cropRect.size.height/2;
    float x = point.x - center.x;
    float y = point.y - center.y;
    int rotation = 90;
    switch(rotation) {
        case 0:
            point.x = x;
            point.y = y;
            break;
        case 90:
            point.x = -y;
            point.y = x;
            break;
        case 180:
            point.x = -x;
            point.y = -y;
            break;
        case 270:
            point.x = y;
            point.y = -x;
            break;
    }
    point.x = point.x + center.x;
    point.y = point.y + center.y;
    return point;
}



#define kTextMargin 10
- (void)drawBackground{
    CGContextRef c = UIGraphicsGetCurrentContext();
	CGFloat white[4] = {1.0f, 1.0f, 1.0f, 0.8f};
	CGContextSetStrokeColor(c, white);
	CGContextSetFillColor(c, white);
    
    CGRect topRect = CGRectMake(0.0, 0.0, self.frame.size.width, cropRect.origin.y);
    CGRect bottomRect = CGRectMake(0.0, cropRect.origin.y + cropRect.size.height, self.frame.size.width, self.frame.size.height - cropRect.origin.y - cropRect.size.height);
    CGRect leftRect = CGRectMake(0.0, cropRect.origin.y, cropRect.origin.x, cropRect.size.height);
    CGRect rightRect = CGRectMake(cropRect.origin.x + cropRect.size.width, cropRect.origin.y, self.frame.size.width - cropRect.origin.x - cropRect.size.width, cropRect.size.height);
    
    [self drawRect:topRect inContext:c fillPath:YES];
    [self drawRect:bottomRect inContext:c fillPath:YES];
    [self drawRect:leftRect inContext:c fillPath:YES];
    [self drawRect:rightRect inContext:c fillPath:YES];

}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    if (displayedMessage == nil) {
        self.displayedMessage = NSLocalizedStringWithDefaultValue(@"OverlayView displayed message", nil, [NSBundle mainBundle], @"Place a barcode inside the viewfinder rectangle to scan it.", @"Place a barcode inside the viewfinder rectangle to scan it.");
    }
    
    
    //	[self drawRect:cropRect inContext:c];
	//画黑色半通明背景
    [self drawBackground];
    CGContextRef c = UIGraphicsGetCurrentContext();
    //画白色矩形
    [self drawRect:cropRect inContext:c fillPath:NO];
    //画绿色聚焦框
    [self drawFocus:cropRect inContext:c];
    
    CGContextSetFillColorWithColor(c, CGColorCreateCopyWithAlpha([UIColor whiteColor].CGColor, 0.8f));
    
	CGContextSaveGState(c);
	if (oneDMode) {
        NSString *text = NSLocalizedStringWithDefaultValue(@"OverlayView 1d instructions", nil, [NSBundle mainBundle], @"Place a red line over the bar code to be scanned.", @"Place a red line over the bar code to be scanned.");
        UIFont *helvetica15 = [UIFont fontWithName:@"Helvetica" size:15];
        CGSize textSize = [text sizeWithFont:helvetica15];
        
		CGContextRotateCTM(c, M_PI/2);
        // Invert height and width, because we are rotated.
        CGPoint textPoint = CGPointMake(self.bounds.size.height / 2 - textSize.width / 2, self.bounds.size.width * -1.0f + 20.0f);
        [text drawAtPoint:textPoint withFont:helvetica15];
        
	}else {
        UIFont *font = [UIFont systemFontOfSize:17.0f];
        CGSize constraint = CGSizeMake(rect.size.width  - 2 * kTextMargin, cropRect.origin.y);
        CGSize displaySize = [self.displayedMessage sizeWithFont:font constrainedToSize:constraint];
        CGRect displayRect = CGRectMake((rect.size.width - displaySize.width) / 2 , cropRect.origin.y / 2 - displaySize.height/2, displaySize.width, displaySize.height);
        [self.displayedMessage drawInRect:displayRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	}
	CGContextRestoreGState(c);
	int offset = rect.size.width / 2;
	if (oneDMode) {
		CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
		CGContextSetStrokeColor(c, red);
		CGContextSetFillColor(c, red);
		CGContextBeginPath(c);
		//		CGContextMoveToPoint(c, rect.origin.x + kPadding, rect.origin.y + offset);
		//		CGContextAddLineToPoint(c, rect.origin.x + rect.size.width - kPadding, rect.origin.y + offset);
		CGContextMoveToPoint(c, rect.origin.x + offset, rect.origin.y + kPadding);
		CGContextAddLineToPoint(c, rect.origin.x + offset, rect.origin.y + rect.size.height - kPadding);
		CGContextStrokePath(c);
	}
	if( nil != _points ) {
		CGFloat blue[4] = {0.0f, 1.0f, 0.0f, 1.0f};
		CGContextSetStrokeColor(c, blue);
		CGContextSetFillColor(c, blue);
		if (oneDMode) {
			CGPoint val1 = [self map:[[_points objectAtIndex:0] CGPointValue]];
			CGPoint val2 = [self map:[[_points objectAtIndex:1] CGPointValue]];
			CGContextMoveToPoint(c, offset, val1.x);
			CGContextAddLineToPoint(c, offset, val2.x);
			CGContextStrokePath(c);
		}
		else {
			CGRect smallSquare = CGRectMake(0, 0, 10, 10);
			for( NSValue* value in _points ) {
				CGPoint point = [self map:[value CGPointValue]];
				smallSquare.origin = CGPointMake(
                                                 cropRect.origin.x + point.x - smallSquare.size.width / 2,
                                                 cropRect.origin.y + point.y - smallSquare.size.height / 2);
				[self drawRect:smallSquare inContext:c fillPath:NO];
			}
		}
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPoints:(NSMutableArray*)pnts {
    [pnts retain];
    [_points release];
    _points = pnts;
	
    if (pnts != nil) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    [self setNeedsDisplay];
}

- (void) setPoint:(CGPoint)point {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    if (_points.count > 3) {
        [_points removeObjectAtIndex:0];
    }
    [_points addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (cancelButton) {
        if (oneDMode) {
            [cancelButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
            [cancelButton setFrame:CGRectMake(20, 175, 45, 130)];
        } else {
            CGSize theSize = CGSizeMake(100, 50);
            CGRect rect = self.frame;
            CGRect theRect = CGRectMake((rect.size.width - theSize.width) / 2, cropRect.origin.y + cropRect.size.height + 20, theSize.width, theSize.height);
            [cancelButton setFrame:theRect];
        }
    }
}

@end
