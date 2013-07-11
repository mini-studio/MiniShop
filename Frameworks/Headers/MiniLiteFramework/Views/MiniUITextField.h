//
//  MiniUITextField.h
//  YContact
//
//  Created by wu quancheng on 11-10-1.
//  Copyright 2011年 Youlu. All rights reserved.
//
@class MiniUITextFieldDelegate;


@interface MiniUITextField : UITextField
{
    id                      userInfo;
    float                   shiftBy;
    CGPoint                 offset;
    MiniUITextFieldDelegate *textFieldDelegate;
    id                      miniUITextFieldDelegate;
    CGRect                  _keyboardBounds;
    BOOL                    _keyBoardVisible;
    BOOL                    _scrolled;
}

@property (nonatomic,assign) id  miniUITextFieldDelegate;
@property (nonatomic,retain) id  userInfo;
@property (nonatomic,assign) BOOL keyBoardVisible;
@property (nonatomic,assign) BOOL scrolled;
@property (nonatomic,assign) CGRect keyboardBounds;

- (void)scrollToBeVisible;

@end



@interface MiniUITextFieldDelegate : NSObject <UITextFieldDelegate> 

@end
