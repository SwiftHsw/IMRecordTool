//
//  ATRecordToolView.m
//  ATRecordManager
//
//  Created by Shiwen Huang on 2018/9/3.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import "ATRecordToolView.h"
#import "IATConfig.h"
#import "IFlyMSC/IFlyMSC.h"
#import "ISRDataHelper.h"
#include "EZAudio.h"
#import "SWKit.h"



#define Length 5
#define Length2 15



@interface ATRecordToolView()<IFlySpeechRecognizerDelegate,IFlyPcmRecorderDelegate,UITextViewDelegate,EZMicrophoneDelegate>
//不带界面的识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;// SDK录音工具
@property (nonatomic, assign) CGPoint origin;                    // 箭头位置
@property (nonatomic, assign) CGFloat height;                    // 视图的高度
@property (nonatomic, assign) CGFloat width;                     // 视图的宽度
@property (nonatomic, assign) XTDirectionType type;              // 箭头位置类型
@property (nonatomic, strong) NSString * result;
@end

static NSString *lastString;

@implementation ATRecordToolView




- (instancetype)initWithOrigin:(CGPoint)origin Width:(CGFloat)width Height:(CGFloat)height Type:(XTDirectionType)type Color:(UIColor *)color
{
    
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.origin = origin;
        self.width = width;
        self.height = height;
        self.type = type;
        self.backGoundView = LOADNIBWITHNAME(@"ATRecordView", nil);
        self.backGoundView.frame = CGRectMake(origin.x, origin.y, width, height);
        [self.backGoundView setComple:^{
              [self.iFlySpeechRecognizer stopListening];
              [self dismiss];
            NSLog(@"===%@",self.backGoundView.textView.text);
        }];
        [self initRecognizer];
        
        [self.backGoundView setCancelBlock:^{
            [self.iFlySpeechRecognizer stopListening];
        }];
        self.backGoundView.textView.delegate =self;
        
        [self addSubview:self.backGoundView];
        [self startRecrod];
        [self startAnmition];
    }
    return self;
}
- (void)startAnmition{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    self.backGoundView.audioPlot.backgroundColor = [UIColor clearColor];
    //
    // Waveform color
    //
    self.backGoundView.audioPlot.color = [UIColor colorWithRed:186/255.0 green:186/255.0 blue:186/255.0 alpha:1];
    
    self.backGoundView.audioPlot.plotType = EZPlotTypeRolling;
    self.backGoundView.audioPlot.shouldFill = YES;
    self.backGoundView.audioPlot.shouldMirror = YES;
    
    self.backGoundView.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    [self.backGoundView.microphone setDevice:[EZAudioDevice inputDevices][0]];
    //
    // Start the microphone
    //
    [self.backGoundView.microphone startFetchingAudio];
}
// 通过给定文字和字体大小在指定的最大宽度下，计算文字实际所占的尺寸
- (CGSize)sizeForLblContent:(NSString *)strContent fixMaxWidth:(CGFloat)w andFondSize:(int)fontSize{
    // 先获取文字的属性，特别是影响文字所占尺寸相关的
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    // 把该属性放到字典中
    NSDictionary *dicAttr = [[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil];
    // 通过字符串的计算文字所占尺寸方法获取尺寸
    CGSize size = [strContent boundingRectWithSize:CGSizeMake(w, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dicAttr context:nil].size;
    return size;
}

- (void)textViewDidChange:(UITextView *)textView
{
   
        NSLog(@"text:%@", textView.text);
    
    
    CGSize calculateSize = [self sizeForLblContent:textView.text fixMaxWidth:_backGoundView.frame.size.width andFondSize:13];
    CGFloat height =  calculateSize.height > 46 ? calculateSize.height+10 : 46+10;
    
    _backGoundView.textHeight.constant = height;
    _backGoundView.height = height + 95;
    
 
}
- (void)startRecrod{
 
    [_backGoundView.textView setText:@""];
    [_backGoundView.textView resignFirstResponder];
    
    NSLog(@"%s[IN]",__func__);
 
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
  
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream as audio source,which requires the developer import audio data into the recognition control by self through "writeAudio:".
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    
    
    if (ret) {
 
        //set the category of AVAudioSession
        [IFlyAudioSession initRecordingAudioSession];
        
        _pcmRecorder.delegate = self;
        
        //start recording
        BOOL ret = [_pcmRecorder start];
 
        NSLog(@"%s[OUT],Success,Recorder ret=%d",__func__,ret);
    }
    else
    {
 
        NSLog(@"%s[OUT],Failed",__func__);
    }
    
}
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    _result =[NSString stringWithFormat:@"%@%@", _backGoundView.textView.text,resultString];
    
    NSString * resultFromJson =  nil;
    
    if([IATConfig sharedInstance].isTranslate){
        
        NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:    //The result type must be utf8, otherwise an unknown error will happen.
                                    [resultString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(resultDic != nil){
            NSDictionary *trans_result = [resultDic objectForKey:@"trans_result"];
            
            if([[IATConfig sharedInstance].language isEqualToString:@"en_us"]){
                NSString *dst = [trans_result objectForKey:@"dst"];
                NSLog(@"dst=%@",dst);
                resultFromJson = [NSString stringWithFormat:@"%@\ndst:%@",resultString,dst];
            }
            else{
                NSString *src = [trans_result objectForKey:@"src"];
                NSLog(@"src=%@",src);
                resultFromJson = [NSString stringWithFormat:@"%@\nsrc:%@",resultString,src];
            }
        }
    }
    else{
        resultFromJson = [ISRDataHelper stringFromJson:resultString];
    }
    
_backGoundView.textView.text = [NSString stringWithFormat:@"%@%@", _backGoundView.textView.text,resultFromJson];
    
    if (isLast){
        NSLog(@"ISR Results(json)：%@",  self.result);
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_backGoundView.textView.text);
   
    [self textViewDidChange:_backGoundView.textView];
    

    
}
//识别会话结束返回代理
- (void)onCompleted: (IFlySpeechError *) error{
    if (error) {
        NSLog(@"==%@",error);
    }
}
//停止录音回调
- (void) onEndOfSpeech{
     [_pcmRecorder stop];
    
    //停止提取音频
    [ self.backGoundView.microphone stopFetchingAudio ];
}
//开始录音回调
- (void) onBeginOfSpeech{
  
}
//音量回调函数
- (void) onVolumeChanged: (int)volume{
    
    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),volume];
    NSLog(@"当前说话的音量===%@",vol);
    
}
//会话取消回调
- (void) onCancel{
      NSLog(@"会话取消回调");
    
}
#pragma mark - IFlyPcmRecorderDelegate

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret)
    {
        [self.iFlySpeechRecognizer stopListening];
 
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}

//range from 0 to 30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    //    NSLog(@"%s,power=%d",__func__,power);
 
}


#pragma mark - Initialization

/**
 initialize recognition conctol and set recognition params
 **/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {
        
        //recognition singleton without view
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        }
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //set recognition domain
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        _iFlySpeechRecognizer.delegate = self;
     
        IATConfig *instance = [IATConfig sharedInstance];
        
        //set timeout of recording
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //set VAD timeout of end of speech(EOS)
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //set VAD timeout of beginning of speech(BOS)
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //set network timeout
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //set sample rate, 16K as a recommended option
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        //set language
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //set accent
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        
        //set whether or not to show punctuation in recognition results
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
        
        //Initialize recorder
        if (_pcmRecorder == nil)
        {
            
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        
        _pcmRecorder.delegate = self;
        
        [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
        
        [_pcmRecorder setSaveAudioPath:nil];    //not save the audio file
 
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.type) {
        case XTTypeOfUpLeft:
        case XTTypeOfUpCenter:
        case XTTypeOfUpRight:{
            {
                CGFloat startX = self.origin.x;
                CGFloat startY = self.origin.y;
                CGContextMoveToPoint(context, startX, startY);
                CGContextAddLineToPoint(context, startX + Length, startY + Length);
                CGContextAddLineToPoint(context, startX - Length, startY + Length);
            }
            break;
        }
        case XTTypeOfDownLeft:
        case XTTypeOfDownCenter:
        case XTTypeOfDownRight: {
            {
                CGFloat startX = self.origin.x;
                CGFloat startY = self.origin.y;
                CGContextMoveToPoint(context, startX, startY);
                CGContextAddLineToPoint(context, startX - Length, startY - Length);
                CGContextAddLineToPoint(context, startX + Length, startY - Length);
            }
            break;
        }
        case XTTypeOfLeftUp:
        case XTTypeOfLeftCenter:
        case XTTypeOfLeftDown: {
            {
                CGFloat startX = self.origin.x;
                CGFloat startY = self.origin.y;
                CGContextMoveToPoint(context, startX, startY);
                CGContextAddLineToPoint(context, startX + Length, startY - Length);
                CGContextAddLineToPoint(context, startX + Length, startY + Length);
            }
            break;
        }
        case XTTypeOfRightUp:
        case XTTypeOfRightCenter:
        case XTTypeOfRightDown: {
            {
                CGFloat startX = self.origin.x;
                CGFloat startY = self.origin.y;
                CGContextMoveToPoint(context, startX, startY);
                CGContextAddLineToPoint(context, startX - Length, startY - Length);
                CGContextAddLineToPoint(context, startX - Length, startY + Length);
            }
            break;
        }
    }
    CGContextClosePath(context);
    [self.backGoundView.backgroundColor setFill];
    [self.backGoundView.backgroundColor setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);
 
}




#pragma mark - popView
- (void)popView
{
    // 同步显示 子控件(views)和(self)
    NSArray *results = [self.backGoundView subviews];
    for (UIView *view in results) {
        [view setHidden:YES];
    }
    UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
    [windowView addSubview:self];
    switch (self.type) {
        case XTTypeOfUpLeft: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y + Length, 0, 0);
                CGFloat origin_x = self.origin.x - Length2;
                CGFloat origin_y = self.origin.y + Length;
                CGFloat size_width = self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfUpCenter: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y + Length, 0, 0);
                CGFloat origin_x = self.origin.x - self.width / 2;
                CGFloat origin_y = self.origin.y + Length;
                CGFloat size_width = self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfUpRight: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y + Length, 0, 0);
                CGFloat origin_x = self.origin.x + Length2;
                CGFloat origin_y = self.origin.y + Length;
                CGFloat size_width = -self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfDownLeft: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y - Length, 0, 0);
                CGFloat origin_x = self.origin.x - Length2;
                CGFloat origin_y = self.origin.y - Length;
                CGFloat size_width = self.width;
                CGFloat size_height = -self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfDownCenter: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y - Length, 0, 0);
                CGFloat origin_x = self.origin.x - self.width / 2;
                CGFloat origin_y = self.origin.y - Length;
                CGFloat size_width = self.width;
                CGFloat size_height = -self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfDownRight: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y - Length, 0, 0);
                CGFloat origin_x = self.origin.x-self.width + Length2;
                CGFloat origin_y = self.origin.y - Length;
                CGFloat size_width = self.width;
                CGFloat size_height = -self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
            
        case XTTypeOfLeftUp: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x + Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x + Length;
                CGFloat origin_y = self.origin.y - Length2;
                CGFloat size_width = self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfLeftCenter: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x + Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x + Length;
                CGFloat origin_y = self.origin.y - self.height / 2;
                CGFloat size_width = self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfLeftDown: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x + Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x + Length;
                CGFloat origin_y = self.origin.y - self.height + Length2;
                CGFloat size_width = self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfRightUp: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x - Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x - Length;
                CGFloat origin_y = self.origin.y - Length2;
                CGFloat size_width = -self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfRightCenter: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x - Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x - Length;
                CGFloat origin_y = self.origin.y - self.height / 2;
                CGFloat size_width = -self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
        case XTTypeOfRightDown: {
            {
                self.backGoundView.frame = CGRectMake(self.origin.x - Length, self.origin.y, 0, 0);
                CGFloat origin_x = self.origin.x - Length;
                CGFloat origin_y = self.origin.y - self.height + Length2;
                CGFloat size_width = -self.width;
                CGFloat size_height = self.height;
                [self startAnimateView_x:origin_x _y:origin_y origin_width:size_width origin_height:size_height];
            }
            break;
        }
    }
}

#pragma mark -
- (void)startAnimateView_x:(CGFloat) x
                        _y:(CGFloat) y
              origin_width:(CGFloat) width
             origin_height:(CGFloat) height
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backGoundView.frame = CGRectMake(x, y, width, height);
    }completion:^(BOOL finished) {
        NSArray *results = [self.backGoundView subviews];
        for (UIView *view in results) {
            [view setHidden:NO];
        }
    }];
}
#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_backGoundView.textView resignFirstResponder];
    
//    if (![[touches anyObject].view isEqual:self.backGoundView]) {
//        [self dismiss];
//    }
}

#pragma mark -
- (void)dismiss
{
    /**
     *  删除 在backGroundView 上的子控件
//     */
    NSArray *results = [self.backGoundView subviews];
    for (UIView *view in results) {
        [view removeFromSuperview];
    }
    [UIView animateWithDuration:0.25 animations:^{
        //
        self.backGoundView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    } completion:^(BOOL finished) {
        //
        [self removeFromSuperview];
    }];
    
}


#pragma mark - EZAudioDelegate

#warning Thread Safety
//
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI
// to work.
//
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as an array of float buffer arrays. What does that mean?
    // Because the audio is coming in as a stereo signal the data is split into
    // a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data
    // for the right channel.
    //
    
    //
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    //
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources.
        // Hence, one badass line of code gets you a pretty plot :)
        //
        [weakSelf.backGoundView.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    //
    // The AudioStreamBasicDescription of the microphone stream. This is useful
    // when configuring the EZRecorder or telling another component what
    // audio format type to expect.
    //
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder or EZOutput. Say whattt...
    //
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    NSLog(@"Microphone changed device: %@", device.name);
    
    //
    // Called anytime the microphone's device changes
    //    //
    //    __weak typeof(self) weakSelf = self;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        NSString *name = device.name;
    //        NSString *tapText = @" (Tap To Change)";
    //        NSString *microphoneInputToggleButtonText = [NSString stringWithFormat:@"%@%@", device.name, tapText];
    //        NSRange rangeOfName = [microphoneInputToggleButtonText rangeOfString:name];
    //        NSMutableAttributedString *microphoneInputToggleButtonAttributedText = [[NSMutableAttributedString alloc] initWithString:microphoneInputToggleButtonText];
    //        [microphoneInputToggleButtonAttributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfName];
    //        [weakSelf.microphoneInputToggleButton setAttributedTitle:microphoneInputToggleButtonAttributedText forState:UIControlStateNormal];
    //
    //        //
    //        // Reset the device list (a device may have been plugged in/out)
    //        //
    //        weakSelf.inputs = [EZAudioDevice inputDevices];
    //        [weakSelf.microphoneInputPickerView reloadAllComponents];
    //        [weakSelf setMicrophonePickerViewHidden:YES];
    //    });
}



@end
