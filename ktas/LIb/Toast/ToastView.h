//
//  ToastView.h
//  Toast
//
//  Created by Office on 2015. 1. 5..
//  Copyright (c) 2015년 Office. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    toastGravityTop = 0x01,
    toastGravityCenter,
    toastGravityBottom,
    toastGravityCustom
}ToastGravity;      //toast 위치

typedef enum {
    toastDurationShort = 0x11,
    toastDurationNormal,
    toastDurationLong
}ToastDuration;     //toast 시간


@interface ToastView : UIView
{
    //Toast Text
    NSString *text;
    //parentView
    UIView *parentsView;
    //customView
    UIView *customView;
    //toast background color
    UIColor *toastBGColor;
    //type
    BOOL defaultType;
}


// initializer로 msg와 parentView 전달, background color는 기본으로 회색이 들어간다.
+ (ToastView *) makeText:(NSString *)_text :(UIView *)_parentsView;
// initializer로 msg와 parentView 전달, background color도 정해준다.
+ (ToastView *) makeText:(NSString *)_text :(UIView *)_parentsView :(UIColor *)_color;
// initializer로 msg와 parentView 전달, 사용자가 정의한 customView를 Toast로 보여주기위함
+ (ToastView *) makeToastView:(UIView *)_parentsView :(UIView *)_customView;

// toast를 보여준다.
- (void) show;
// toast를 보여준다. : 위치지정
- (void) show:(ToastGravity) gravity;
// toast를 보여준다. : 위치지정 : 시간지정
- (void) show:(ToastGravity) gravity :(ToastDuration) duration;
// toast를 보여준다. : 위치지정 : 시간지정
- (void) showAtPoint:(CGPoint) toastCenterPoint :(ToastDuration) duration;




@end

