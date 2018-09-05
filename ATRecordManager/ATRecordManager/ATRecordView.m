//
//  ATRecordView.m
//  ATRecordManager
//
//  Created by Shiwen Huang on 2018/9/3.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import "ATRecordView.h"




/* 设置圆角边框*/
#define ATViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]


@interface ATRecordView()
@property (nonatomic, strong) NSArray *inputs;
@end

@implementation ATRecordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    
    ATViewBorderRadius(self, 5, 1, [[UIColor grayColor]colorWithAlphaComponent:.1]);

}

 

- (IBAction)compClick:(id)sender {
    //说完了
    self.comple();
    
}
- (IBAction)cancel:(id)sender {
    //取消
    [self.superview removeFromSuperview];
    self.cancelBlock();
    
}


@end
