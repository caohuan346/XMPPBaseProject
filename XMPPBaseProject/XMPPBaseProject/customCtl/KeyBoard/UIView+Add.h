//
//  UIView+Add.h
//  
//
//  
//  
//

#import <UIKit/UIKit.h>

@interface UIView (Add)
+ (UITextField *)findFistResponder:(UIView *)view;
+ (UITextView *)findFistResponderToTextView:(UIView *)view;
+ (UIView *)findFistResponderUIView:(UIView *)view;
@end
