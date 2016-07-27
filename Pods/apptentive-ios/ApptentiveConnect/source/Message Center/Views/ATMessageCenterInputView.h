//
//  ATMessageCenterInputView.h
//  ApptentiveConnect
//
//  Created by Frank Schmitt on 7/14/15.
//  Copyright (c) 2015 Apptentive, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATAttachButton;


@interface ATMessageCenterInputView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet ATAttachButton *attachButton;
@property (weak, nonatomic) IBOutlet UITextView *messageView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *sendBar;

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (assign, nonatomic) UIInterfaceOrientation orientation;

@end
