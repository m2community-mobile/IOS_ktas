
#import "ToastView.h"

@implementation ToastView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// initializer로 msg와 parentView 전달, background color는 기본으로 회색이 들어간다.
+ (ToastView *) makeText:(NSString *)_text :(UIView *)_parentsView {
    //기본으로 gray컬러가 들어감
    ToastView *toast = [[ToastView alloc] initWithText:_text :_parentsView :[UIColor grayColor]];
    
    return toast;
}

// initializer로 msg와 parentView 전달, background color도 정해준다.
+ (ToastView *) makeText:(NSString *)_text :(UIView *)_parentsView :(UIColor *)_color{
    // 전달된 text와 background color 적용
    ToastView *toast = [[ToastView alloc] initWithText:_text :_parentsView :_color];
    
    return toast;
}

// initializer로 default 타입일 경우 호출된다.
- (id) initWithText:(NSString *) _text :(UIView *)_parentsView :(UIColor *)_color{
    if (self = [super init]) {
        parentsView = _parentsView; //부모View
        text = [_text copy];        //toast 메시지
        toastBGColor = _color;      //bgColor
        
        defaultType = true;         //toast type은 default..
    }
    
    return self;
}

// initializer로 msg와 parentView 전달, 사용자가 정의한 customView를 Toast로 보여주기위함
+ (ToastView *) makeToastView:(UIView *)_parentsView :(UIView *)_customView {
    ToastView *toast = [[ToastView alloc] initWithView:_parentsView :_customView];
    
    return toast;
}

// initializer로 custom 타입일 경우 호출된다.
- (id) initWithView:(UIView *)_parentsView :(UIView *)_customView {
    if (self = [super init]) {
        parentsView = _parentsView; //부모View
        customView = _customView;   //사용자가 정의하여 전달한 customView
        
        defaultType = false;        //default type이 아니므로 false임
    }
    
    return self;
}

// toast를 보여준다.
- (void) show {
    // 기본적으로 화면 하단에 normal 시간으로 보여준다.
    [self show:toastGravityBottom :toastDurationNormal :CGPointZero];
}

// toast를 보여준다. : 위치지정
- (void) show:(ToastGravity) gravity {
    // 전달받은 gravity에 보여준다.
    [self show:gravity :toastDurationNormal :CGPointZero];
}

// toast를 보여준다. : 위치지정 : 시간지정
- (void) show:(ToastGravity) gravity :(ToastDuration) duration{
    // 전달받은 gravity와 duration만큼 보여준다.
    [self show:gravity :duration :CGPointZero];
}

// toast를 보여준다. : 위치지정 : 시간지정
- (void) showAtPoint:(CGPoint) toastCenterPoint :(ToastDuration) duration{
    //지정된 point를 center로 하여 duration만큼 보여준다.
    [self show:toastGravityCustom :duration :toastCenterPoint];
}

// toast를 보여준다. 위치와 시간, centerPoint가 있으면 그부분에 toast를 보여준다.
- (void) show:(ToastGravity) gravity :(ToastDuration) duration :(CGPoint)toastCenterPoint{
    //Device Width, Height get....
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    CGFloat windowWidth = window.frame.size.width;
    CGFloat windowHeight = window.frame.size.height;
    
    UIView *toastView;
    if ( defaultType == true ) {    //default type의 토스트면 text label만 보여준다.
        // Text를 표시할 Label
        UILabel *label = [self getToastLabel:windowWidth :windowHeight];
        //label을 addview... 여백도...
        toastView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
                                                            label.frame.size.width + 30,
                                                            label.frame.size.height + 20)];
        toastView.backgroundColor = toastBGColor;       //Background color
        toastView.layer.cornerRadius = 5;               //사각형의 꼭지점을 둥글게...
        
        //gravity에 따른 tost위치조정
        if (gravity == toastGravityCustom) {
            toastView.center = toastCenterPoint;        //전달받은 point가 있으면 그곳을 center로 보여준다.
        }else{                                          //전달받은 gravity에 따라 위치가 정해진다.
            toastView.center = [self getToastCenterPoint:gravity :windowWidth :windowHeight :label.frame.size.height];
        }
        label.center = CGPointMake(toastView.frame.size.width / 2, toastView.frame.size.height / 2); //msg 영역은 toastView 전체의 center
        [toastView addSubview:label];
    }
    
    else {                      //custom type이면
        CGFloat viewWidth = customView.frame.size.width;        //전달받은 View사이즈 그대로...
        CGFloat viewHeight = customView.frame.size.height;
        
        toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        if (gravity == toastGravityCustom) {    //전달받은 point가 있으면 그곳을 center로 보여주고
            toastView.center = toastCenterPoint;
        }else{                                  //아니면 gravity에 보여준다.
            toastView.center = [self getToastCenterPoint:gravity :windowWidth :windowHeight :viewHeight];
        }
        
        [toastView addSubview:customView];
    }
    
    //안드로이드 처럼 투명한상태에서 서서히 나타나는 animation으로 show
    self.alpha = 0;
    [self addSubview:toastView];
    [parentsView addSubview:self];
    [UIView beginAnimations:nil context:nil];
    self.alpha = 1;
    
    [UIView commitAnimations];
    
    // Timer를 Duration만큼 Set하고 시간이 지나면 hideToast를 호출...
    NSTimer *timer = [NSTimer timerWithTimeInterval:[self setDuration:duration]
                                             target:self selector:@selector(hideToast) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

// text 길이에 따른 제한을 위해 Label에 대한 상세 속성을 부여한다.
- (UILabel *)getToastLabel:(CGFloat)windowWidth :(CGFloat)windowHeight {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];            //label 초기화한다.
    label.frame = [self setLabelSize:label :0.8 * windowWidth :0.3 * windowHeight];     //label의 최대크기를 제한한다.
    label.numberOfLines = 0;                                                            //multiline으로 한다.
    label.backgroundColor = [UIColor clearColor];                                       //투명한 color
    label.text = text;                                                                  //toast message
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];                                             //text color
    
    return label;
}

/** 가변적인 Text길이에 따른 Resizing */
- (CGRect)setLabelSize:(UILabel *)label :(CGFloat)labelMaxWidth :(CGFloat)labelMaxHeight{
    //label Max size define
    CGSize maximumLabelSize = CGSizeMake(labelMaxWidth, labelMaxHeight);

    //
    
    NSDictionary *attributes = @{NSFontAttributeName: label.font};
    
    CGRect rect = [text boundingRectWithSize:maximumLabelSize
                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                    attributes:attributes
                                       context:nil];
    CGSize expectedLabelSize = rect.size;
    
    //
    
//    CGSize expectedLabelSize = [text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];

    //text wrap size
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    newFrame.size.height = expectedLabelSize.height;
    
    return newFrame;
}

// 전달된 gravity에 따라 point를 정한다.
- (CGPoint)getToastCenterPoint:(ToastGravity) gravity :(CGFloat) windowWidth :(CGFloat) windowHeight :(CGFloat) toastHeight {
    CGPoint toastCenterPoint;
    
    switch (gravity) {
        case toastGravityTop:       //상단
            toastCenterPoint = CGPointMake(windowWidth / 2, (toastHeight / 2) + (0.05 * windowHeight) );
            break;
            
        case toastGravityCenter:    //가운데
            toastCenterPoint = CGPointMake(windowWidth / 2, windowHeight / 2);
            break;
            
        case toastGravityBottom:    //하단
            toastCenterPoint = CGPointMake(windowWidth / 2, windowHeight - ((toastHeight / 2) + 0.2 * windowHeight));
            break;
            
        default:                    //기본적으로 하단
            toastCenterPoint = CGPointMake(windowWidth / 2, windowHeight - ((toastHeight / 2) + 0.1 * windowHeight));
            break;
    }
    
    return toastCenterPoint;
}

// 전달된 duration에 따른 시간을 정한다.
- (NSInteger)setDuration:(ToastDuration)duration {
    NSInteger durationSec = 4;
    
    switch (duration) {
        case toastDurationShort:    //short는 2초
            durationSec = 1;
            break;
            
        case toastDurationNormal:   //normal 4초
            durationSec = 4;
            break;
            
        case toastDurationLong:     //long이면 6초
            durationSec = 6;
            break;
        default:
            durationSec = 4;        //기본은 4초
            break;
    }
    
    return durationSec;
}

// duration이 지나면 toast 를 없앤다.
- (void) hideToast {
    // 투명해지며 서서히 없어지는 애니메이션 효과를 준다.
    self.alpha = 1;
    [UIView beginAnimations:nil context:nil];
    self.alpha = 0;
    
    [UIView commitAnimations];
    // 애니메이션이 끝나면 부모뷰에서 삭제한다.
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(removeToast) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

//애니메이션이 끝나면 부모뷰에서 삭제한다.
- (void) removeToast {
//    NSLog(@"removeToast");
    [self removeFromSuperview];
}



@end
