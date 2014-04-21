//
//  RegisterViewCtl.h
//  BaseProject
//
//  Created by caohuan on 13-12-20.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewCtl : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIToolbar *keyboardToolbar_;
    UIPickerView *genderPickerView_;
    UIDatePicker *birthdayDatePicker_;
    
    NSDate *birthday_;
    NSString *gender_;
    UIImage *photo_;
}

@property(nonatomic, weak) IBOutlet UITextField *nameTextField;
@property(nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property(nonatomic, weak) IBOutlet UITextField *emailTextField;
@property(nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property(nonatomic, weak) IBOutlet UITextField *birthdayTextField;
@property(nonatomic, weak) IBOutlet UITextField *genderTextField;
@property(nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property(nonatomic, weak) IBOutlet UIButton *photoButton;
@property(nonatomic, weak) IBOutlet UITextView *termsTextView;

@property(nonatomic, weak) IBOutlet UILabel *emailLabel;
@property(nonatomic, weak) IBOutlet UILabel *passwordLabel;
@property(nonatomic, weak) IBOutlet UILabel *birthdayLabel;
@property(nonatomic, weak) IBOutlet UILabel *genderLabel;
@property(nonatomic, weak) IBOutlet UILabel *phoneLabel;

@property(nonatomic, strong) UIToolbar *keyboardToolbar;
@property(nonatomic, strong) UIPickerView *genderPickerView;
@property(nonatomic, strong) UIDatePicker *birthdayDatePicker;

@property(nonatomic, strong) NSDate *birthday;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic, strong) UIImage *photo;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)registerToServer:(id)sender;
- (IBAction)cancelRegist:(id)sender;

- (void)resignKeyboard:(id)sender;
- (void)previousField:(id)sender;
- (void)nextField:(id)sender;
- (id)getFirstResponder;
- (void)animateView:(NSUInteger)tag;
- (void)checkBarButton:(NSUInteger)tag;
- (void)checkSpecialFields:(NSUInteger)tag;
- (void)setBirthdayData;
- (void)setGenderData;
- (void)birthdayDatePickerChanged:(id)sender;
- (void)signup:(id)sender;
- (void)resetLabelsColors;

+ (UIColor *)labelNormalColor;
+ (UIColor *)labelSelectedColor;

@end
