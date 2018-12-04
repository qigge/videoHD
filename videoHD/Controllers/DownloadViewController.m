//
//  DownloadViewController.m
//  videoHD
//
//  Created by qianfeng on 15/11/5.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
}

- (void)createView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    titleLabel.text = @"下载";
    [titleLabel setTextColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 50, 30);
    [editBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"btn_green_s_setting"] forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"btn_green_s_setting_pressed"] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
}
- (void)back {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)closeVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
