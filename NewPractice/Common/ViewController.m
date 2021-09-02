//
//  ViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/8/7.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "ViewController.h"
#import "MLifeViewController.h"
#import "BaseViewController.h"
#import "LocationNotiViewController.h"
#import "EmojiKBViewController.h"
#import "ImgScaleViewController.h"
#import "LottieController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTab;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *vcArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Catalogue";
    self.titleArray = [@[@"MLife",@"Lottie动画",@"图片缩放",@"表情键盘",@"图片多选",@"本地通知"] mutableCopy];
    self.vcArray = [@[@"MLifeViewController",@"LottieController",@"ImgScaleViewController",@"EmojiKBViewController",@"PhotosViewController",@"LocationNotiViewController"] mutableCopy];
    
    [self initTabView];
    [self.myTab reloadData];
}
-(void)initTabView
{
    _myTab = [[UITableView alloc] init];
    _myTab.delegate = self;
    _myTab.dataSource = self;
    [self.view addSubview:_myTab];
    
    [_myTab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(0);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(0);
            
        } else {
            make.top.equalTo(self.view).offset(10);
            make.bottom.equalTo(self.view).offset(0);
        }
        
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseViewController * nextVC = [[NSClassFromString(self.vcArray[indexPath.row]) alloc] init];
    nextVC.title = self.titleArray[indexPath.row];
    [self.navigationController pushViewController:nextVC animated:YES];
}
@end
