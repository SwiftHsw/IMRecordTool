//
//  ViewController.m
//  ATRecordManager
//
//  Created by Shiwen Huang on 2018/9/3.
//  Copyright © 2018年 Shiwen Huang. All rights reserved.
//

#import "ViewController.h"
#import "ATRecordToolView.h"

@interface ViewController ()
@property (nonatomic,strong)ATRecordToolView *ssss;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showManager:(id)sender {
    UIButton *btn = (UIButton *)sender;
    CGPoint point = CGPointMake(btn.center.x,btn.frame.origin.y);
    _ssss = [[ATRecordToolView alloc] initWithOrigin:point Width:ScreenWidth -100 Height:141 Type:XTTypeOfRightCenter Color:[UIColor  clearColor]];
    [_ssss popView];
}


@end
