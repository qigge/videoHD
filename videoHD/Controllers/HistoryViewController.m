//
//  HistoryViewController.m
//  videoHD
//
//  Created by qianfeng on 15/11/4.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "HistoryViewController.h"
#import "CourseTableViewCell.h"
#import "DetailViewController.h"

#import "NewCourseModel.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_historyTableView;
    UIView *_bottomView;
    NSMutableArray *_dataArr;
    NSMutableArray *_editArr;
    BOOL _isEdit;
}

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    _dataArr = [NSMutableArray array];
    _editArr = [NSMutableArray array];
    _isEdit = NO;
    [super viewDidLoad];
    
    [self createView];
}
// 创建视图
- (void)createView {
    // 导航栏左侧返回
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 80, 20);
    [backBtn setTitle:@"播放历史" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [backBtn setImage:[UIImage imageNamed:@"ico_arrow_left"] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, 50, 30);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"btn_green_s_setting"] forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"btn_green_s_setting_pressed"] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(editBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    _historyTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _historyTableView.dataSource = self;
    _historyTableView.delegate = self;
    [self.view addSubview:_historyTableView];
    
    // 底部的view
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-114, self.view.frame.size.width, 50)];
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    _bottomView.hidden = YES;
    [self.view addSubview:_bottomView];
    
    
    CGFloat widthOfBtn = self.view.frame.size.width/2-100;
    // 下面的全选按钮，和删除按钮
    UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectAllBtn.frame = CGRectMake(80, 10, widthOfBtn, 30);
    [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectAllBtn setBackgroundImage:[UIImage imageNamed:@"btn_update"] forState:UIControlStateNormal];
    [selectAllBtn setBackgroundImage:[UIImage imageNamed:@"btn_update_pressed"] forState:UIControlStateHighlighted];
    [selectAllBtn addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:selectAllBtn];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(self.view.frame.size.width-80-widthOfBtn, 10, widthOfBtn, 30);
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"btn_green_s_setting"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"btn_green_s_setting_pressed"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:deleteBtn];
}

// 从数据库获取数据
- (void)getDataFromDb {
    SQLManager *manager = [SQLManager manager];
    [manager.database inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from history left join course on fav.plid = course.plid"];
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
//            NSNumber *num = [NSNumber numberWithInt:];
            model.playIndex = [resultSet intForColumn:@"play_index"];
            [_dataArr addObject:model];
        }
        [resultSet close];
        [_historyTableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate
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
    // 显示编辑图标
    cell.check_boxImageView.hidden = !_isEdit;
    cell.check_boxImageView.image = [UIImage imageNamed:@"check_box"];
    for (NewCourseModel *newModel in _editArr) {
        if (newModel == model) {
            cell.check_boxImageView.image = [UIImage imageNamed:@"check_box_selected"];
        }
    }
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
    cell.titLabel.text = model.title;
    cell.tagLabel.text = [NSString stringWithFormat:@"分类：%@",model.tags];
    cell.countLabel.text = [NSString stringWithFormat:@"集数：%@    已译：%@",model.playcount,model.updated_playcount];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewCourseModel *model = _dataArr[indexPath.row];
    if (!_isEdit) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        detailVC.plid = model.plid;
        detailVC.playIndex = model.playIndex;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else {
        BOOL flag = YES;
        for (NewCourseModel *newModel in _editArr) {
            if (newModel == model) {
                [_editArr removeObject:newModel];
                flag = NO;
                break;
            }
        }
        if (flag) {
            [_editArr addObject:model];
        }
        [_historyTableView reloadData];
    }
}

- (void)back {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
// 编辑状态
- (void)editBtn:(UIButton *)btn {
    [_editArr removeAllObjects];
    // 改变编辑状态
    _isEdit = !_isEdit;
    // 显示顶部按钮
    [UIView animateWithDuration:0.4 animations:^{
        _bottomView.hidden = !_isEdit;
    }];
    if (_isEdit) {
        // 是编辑
        _historyTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
    }else {
        _historyTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    [_historyTableView reloadData];
}
// 全选
- (void)selectAll:(UIButton *)btn {
    [_editArr removeAllObjects];
    if ([btn.titleLabel.text isEqualToString:@"全选"]) {
        [btn setTitle:@"取消全选" forState:UIControlStateNormal];
        [_editArr addObjectsFromArray:_dataArr];
    }else {
        [btn setTitle:@"全选" forState:UIControlStateNormal];
    }
    [_historyTableView reloadData];
}
// 删除
- (void)delete:(UIButton *)btn {
    SQLManager *manager = [SQLManager manager];
    [manager.database inDatabase:^(FMDatabase *db) {
        for (NewCourseModel *model in _editArr) {
            if ([db executeUpdate:[NSString stringWithFormat:@"delete from history where plid = '%@'",model.plid]]) {
                NSLog(@"delete");
            }
        }
        [_editArr removeAllObjects];
        [_historyTableView reloadData];
    }];
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
