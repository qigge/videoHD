//
//  SearchViewController.m
//  videoHD
//
//  Created by qianfeng on 15/11/4.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "SearchViewController.h"
#import "CourseTableViewCell.h"
#import "DetailViewController.h"

#import "NewCourseModel.h"

@interface SearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField *_searchTextField;
    
    UITableView *_searchTableView;
    
    NSMutableArray *_dataArr;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArr = [NSMutableArray array];
    
    [self createView];
}

- (void)createView {
    // 导航栏左侧返回
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ico_arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    _searchTextField.placeholder = @"搜索你感兴趣的课程";
    _searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索你感兴趣的课程" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    _searchTextField.textColor = [UIColor whiteColor];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.delegate = self;
    [_searchTextField addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    [_searchTextField becomeFirstResponder];
    self.navigationItem.titleView = _searchTextField;
    
    _searchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _searchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _searchTableView.dataSource = self;
    _searchTableView.delegate = self;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_searchTableView];
}
// 搜索数据库数据
- (void)searchDataFromDbWithStr:(NSString *)str {
    [_dataArr removeAllObjects];
    SQLManager *manager = [SQLManager manager];
    [manager.database inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from course where title like '%%%@%%'",str]];
        while ([resultSet next]) {
            NewCourseModel *model = [[NewCourseModel alloc] init];
            model.plid = [resultSet stringForColumn:@"plid"];
            model.title = [resultSet stringForColumn:@"title"];
            model.subtitle = [resultSet stringForColumn:@"subtitle"];
            model.desc = [resultSet stringForColumn:@"desc"];
            model.imageurl = [resultSet stringForColumn:@"imageurl"];
            model.lastTime = [resultSet stringForColumn:@"lastTime"];
            model.hits = [resultSet stringForColumn:@"hits"];
            model.playcount = [resultSet stringForColumn:@"playcount"];
            model.updated_playcount = [resultSet stringForColumn:@"updated_playcount"];
            model.tags = [resultSet stringForColumn:@"tags"];
            model.source = [resultSet stringForColumn:@"source"];
            [_dataArr addObject:model];
        }
        [resultSet close];
        [_searchTableView reloadData];
    }];
}

#pragma maek -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedId = @"reused";
    CourseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    if (!cell) {
        cell = [[CourseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    NewCourseModel *model = _dataArr[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
    cell.titLabel.text = model.title;
    cell.tagLabel.text = [NSString stringWithFormat:@"分类：%@",model.tags];
    cell.countLabel.text = [NSString stringWithFormat:@"集数：%@    已译：%@",model.playcount,model.updated_playcount];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchTextField endEditing:YES];
    
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    NewCourseModel *model = _dataArr[indexPath.row];
    detailVC.plid = model.plid;
    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}
- (void)search:(UITextField *)textField {
    NSString *searchStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![searchStr isEqualToString:@""] ) {
        [self searchDataFromDbWithStr:textField.text];
    }else {
        [_dataArr removeAllObjects];
        [_searchTableView reloadData];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationItem.titleView endEditing:YES];
}

- (void)back {
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
