//
//  ATRecordToolView.h
//  ATRecordManager
//
//  Created by Shiwen Huang on 2018/9/3.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATRecordView.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define Length 5
#define Length2 15

typedef NS_ENUM(NSInteger,XTDirectionType) {
    XTTypeOfUpLeft,     // 上左
    XTTypeOfUpCenter,   // 上中
    XTTypeOfUpRight,    // 上右
    
    XTTypeOfDownLeft,   // 下左
    XTTypeOfDownCenter, // 下中
    XTTypeOfDownRight,  // 下右
    
    XTTypeOfLeftUp,     // 左上
    XTTypeOfLeftCenter, // 左中
    XTTypeOfLeftDown,   // 左下
    
    XTTypeOfRightUp,    // 右上
    XTTypeOfRightCenter,// 右中
    XTTypeOfRightDown,  // 右下
};





@interface ATRecordToolView : UIView
- (instancetype _Nonnull)initWithOrigin:(CGPoint) origin
                                  Width:(CGFloat) width
                                 Height:(CGFloat) height
                                   Type:(XTDirectionType)type
                                  Color:( UIColor * _Nonnull ) color;
- (void)popView;

 
// backGoundView
@property (nonatomic, strong) ATRecordView  * _Nonnull backGoundView;
// titles
@property (nonatomic, strong) NSArray * _Nonnull dataArray;
// images
@property (nonatomic, strong) NSArray * _Nonnull images;
// height
@property (nonatomic, assign) CGFloat row_height;
// font
@property (nonatomic, assign) CGFloat fontSize;
// textColor
@property (nonatomic, strong) UIColor * _Nonnull titleTextColor;
// delegate
//@property (nonatomic, assign) id <ATRecordToolViewDelegate> _Nonnull delegate;
@end
