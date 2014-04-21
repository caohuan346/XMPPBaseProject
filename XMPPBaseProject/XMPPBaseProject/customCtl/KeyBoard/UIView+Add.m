//
//  UIView+Add.m
// 
//
// 
// //

#import "UIView+Add.h"

@implementation UIView (Add)
#pragma mark 递归找出第一响应者
+ (UITextField *)findFistResponder:(UIView *)view {
    for (UIView *child in view.subviews) {
        if ([child respondsToSelector:@selector(isFirstResponder)]
            &&
            [child isFirstResponder]) {
            return (UITextField *)child;
        }
        
        UITextField *field = [self findFistResponder:child];
        if (field) {
            return field;
        }
    }
    
    return nil;
}
+ (UITextView *)findFistResponderToTextView:(UIView *)view {
    for (UIView *child in view.subviews) {
        if ([child respondsToSelector:@selector(isFirstResponder)]
            &&
            [child isFirstResponder]) {
            return (UITextView *)child;
        }
        
        UITextView *field = [self findFistResponderToTextView:child];
        if (field) {
            return field;
        }
    }
    
    return nil;
}
+ (UIView *)findFistResponderUIView:(UIView *)view {
    for (UIView *child in view.subviews) {
        if ([child respondsToSelector:@selector(isFirstResponder)]
            &&
            [child isFirstResponder]) {
            return (UIView *)child;
        }
        
        UIView *field = [self findFistResponderUIView:child];
        if (field) {
            return field;
        }
    }
    
    return nil;
}
@end
