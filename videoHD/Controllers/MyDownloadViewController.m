//
//  MyDownloadViewController.m
//  videoHD
//
//  Created by qianfeng on 15/11/5.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "MyDownloadViewController.h"

@interface MyDownloadViewController ()

@end

@implementation MyDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
}

- (void)createView {
    // 导航栏左侧返回
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 80, 20);
    [backBtn setTitle:@"我的下载" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [backBtn setImage:[UIImage imageNamed:@"ico_arrow_left"] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}
- (void)back {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
