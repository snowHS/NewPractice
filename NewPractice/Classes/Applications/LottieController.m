//
//  LottieController.m
//  NewPractice
//
//  Created by sifangL on 2021/9/1.
//  Copyright © 2021 SL123. All rights reserved.
//

#import "LottieController.h"
#import <Lottie/Lottie.h>

#define Start @"start"
#define Pause @"pause"
#define Stop @"stop"
@interface LottieController ()
{
    LOTAnimationView * aniView;
    UIButton * btn;
    UIButton * stopBtn;
}

@end

@implementation LottieController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initViews];
}

- (void)initViews
{
    aniView = [LOTAnimationView animationNamed:@"ok.json"];
    [self.view addSubview:aniView];
    
    aniView.loopAnimation = YES;
    aniView.animationSpeed = 0.5;
    
    aniView.backgroundColor = [UIColor blackColor];
    [aniView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(200);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
        
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(aniView.mas_bottom).offset(40);
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.equalTo(self.view);
    }];
    [btn setTitle:Start forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [StaticTools setRoundView:btn radius:8 borderWidth:0.5 color:[UIColor grayColor]];
    
    stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn.mas_bottom).offset(20);
        [self.view addSubview:stopBtn];
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.equalTo(self.view);
    }];
    [stopBtn setTitle:Stop forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [StaticTools setRoundView:stopBtn radius:8 borderWidth:0.5 color:[UIColor grayColor]];
    
}

- (void)btnClick:(UIButton *)abtn
{
    if ([abtn.titleLabel.text isEqualToString:Start]) {
        
        [aniView playWithCompletion:^(BOOL animationFinished) {
        }];
        [btn setTitle:Pause forState:UIControlStateNormal];
    }
    else if ([abtn.titleLabel.text isEqualToString:Pause]) {
        
        [aniView pause];
        [btn setTitle:Start forState:UIControlStateNormal];

    }
    else if ([abtn.titleLabel.text isEqualToString:Stop]) {
        
        [aniView stop];
        [btn setTitle:Start forState:UIControlStateNormal];

    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
