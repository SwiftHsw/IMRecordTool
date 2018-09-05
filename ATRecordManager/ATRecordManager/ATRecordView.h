//
//  ATRecordView.h
//  ATRecordManager
//
//  Created by Shiwen Huang on 2018/9/3.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EZAudio.h"


@interface ATRecordView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *comp;
//@property (weak, nonatomic) IBOutlet UIView *anminView;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;

@property (nonatomic, strong) EZMicrophone *microphone;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeight;
@property (nonatomic,copy) void (^cancelBlock)(void);
@property (nonatomic,copy) void (^comple)(void);

@end
