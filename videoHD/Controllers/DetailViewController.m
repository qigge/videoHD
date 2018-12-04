//
//  DetailViewController.m
//  videoHD
//
//  Created by Mr.w on 15/10/31.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "DetailViewController.h"

#import "DownloadViewController.h"
#import "MoviePlayerViewController.h"

#import "NewCourseModel.h"
#import "CourseTableViewCell.h"
#import "CommentTableViewCell.h"
#import "VideoListTableViewCell.h"

#define COURSEURL @"http://mobile.open.163.com/movie/%@/getMoviesForAndroid.htm"
#define COMMENTURL @"http://comment.api.163.com/api/json/post/list/normal/video_bbs/%@/desc/%ld/%ld/10/2/2"

#define HOTCOMMENTURL @"http://comment.api.163.com/api/json/post/list/hot/video_bbs/%@/0/5/10/2/2"


@interface DetailViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    CGFloat _screenWidth;
    UIButton *_btnOfFav; // 收藏按钮
    
    UIImageView *_indicatorOfBtn;// 顶部按钮下的选中状态
    
    UIScrollView *_mainScrollView;
    
    UIScrollView *_introduceScrollView;
    
    UITableView *_courseTableView;
    NSMutableArray *_courseList;  // 此课程的集数信息
    
    UITableView *_recommentTableView; // 相关推荐
    NSMutableArray *_recommentList;
    
    UITableView *_commentTableView;
    NSMutableArray *_hotCommentList;
    NSMutableArray *_normalCommentList;
    NSInteger _star;
    
    UILabel *_titleLabel;
    UILabel *_typeLabel;
    UILabel *_schoolLabel;
    UILabel *_teachLabel;
    UILabel *_descLabel;
    
    UIButton *_btnOfComment;
    
    dispatch_queue_t _globalQueue;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _courseList = [NSMutableArray array];
    _recommentList = [NSMutableArray array];
    _hotCommentList = [NSMutableArray array];
    _normalCommentList = [NSMutableArray array];
    
    _star = 0;
    _playIndex = 0;
    
    [self createView];
    [self createIntroduce];
    [self createCourses];
    [self createRecomment];
    [self createComment];
    
    [self getDataFromNet];
    
}

#pragma mark - 创建视图
// 创建主视图
- (void)createView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 导航栏左侧返回
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 60, 20);
    [backBtn setTitle:@"详情" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [backBtn setImage:[UIImage imageNamed:@"ico_arrow_left"] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    // 右侧的两个按钮  观看历史，搜索
    UIView *rightbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 77, 44)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarView];
    
    _btnOfFav = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnOfFav.frame = CGRectMake(0, 10, 22, 22);
    [_btnOfFav setImage:[UIImage imageNamed:@"ico_course_favorites_iphone"] forState:UIControlStateNormal];
    [_btnOfFav addTarget:self action:@selector(fav:) forControlEvents:UIControlEventTouchUpInside];
    [rightbarView addSubview:_btnOfFav];
    
    UIButton *btnOfDown = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfDown.frame = CGRectMake(50, 10, 22, 22);
    [btnOfDown setImage:[UIImage imageNamed:@"ico_course_download_iphone"] forState:UIControlStateNormal];
    [btnOfDown addTarget:self action:@selector(down:) forControlEvents:UIControlEventTouchUpInside];
    [rightbarView addSubview:btnOfDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarView];
    
    // 播放界面
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 190)];
    [self.view addSubview:playView];
    UIImageView *playBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 190)];
    playBgView.image = [UIImage imageNamed:@"bg_me_green"];
    playBgView.userInteractionEnabled= YES;
    [playView addSubview:playBgView];
    
    UIImageView *playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth/2-21, 40, 42, 42)];
    playImageView.image = [UIImage imageNamed:@"md_btn_play_n"];
    playImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *playTapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)];
    [playImageView addGestureRecognizer:playTapGest];
    [playBgView addSubview:playImageView];
    
    // 导航栏下的导航条背景色
    UIImageView *bottomNavBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190, _screenWidth, 45)];
    bottomNavBgView.userInteractionEnabled = YES;
    bottomNavBgView.image = [UIImage imageNamed:@"bottomnav_bg"];
    [self.view addSubview:bottomNavBgView];
    
    CGFloat widthOfNav = _screenWidth/4;
    //
    UIButton *btnOfIntro = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfIntro.frame = CGRectMake(0, 0, widthOfNav, 43);
    [btnOfIntro setTitle:@"简介" forState:UIControlStateNormal];
    [btnOfIntro setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfIntro addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfIntro];
    
    UIButton *btnOfCourse = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfCourse.frame = CGRectMake(widthOfNav, 0, widthOfNav, 45);
    [btnOfCourse setTitle:@"目录" forState:UIControlStateNormal];
//    [btnOfCourse setTitleColor:[UIColor colorWithRed:37/255.0 green:119/255.0 blue:57/255.0 alpha:1.0] forState:UIControlStateNormal];
    [btnOfCourse setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfCourse addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfCourse];
    
    UIButton *btnOfRecommend = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfRecommend.frame = CGRectMake(widthOfNav*2, 0, widthOfNav, 45);
    [btnOfRecommend setTitle:@"相关推荐" forState:UIControlStateNormal];
    [btnOfRecommend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfRecommend addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfRecommend];
    
    _btnOfComment = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnOfComment.frame = CGRectMake(widthOfNav*3, 0, widthOfNav, 45);
    [_btnOfComment setTitle:@"跟帖" forState:UIControlStateNormal];
    [_btnOfComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnOfComment addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:_btnOfComment];
    
    _indicatorOfBtn = [[UIImageView alloc] initWithFrame:CGRectMake(widthOfNav, 42, widthOfNav, 3)];
    _indicatorOfBtn.image = [UIImage imageNamed:@"indicator_49x3"];
    [bottomNavBgView addSubview:_indicatorOfBtn];
    
    // 下面的主视图
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 235, _screenWidth, self.view.frame.size.height-235)];
    _mainScrollView.contentSize = CGSizeMake(4*_screenWidth, self.view.frame.size.height-235);
    _mainScrollView.contentOffset = CGPointMake(_screenWidth, 0);
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
}
// 创建简介
- (void)createIntroduce {
    _introduceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, self.view.frame.size.height-300)];
    _introduceScrollView.contentSize = CGSizeMake(_screenWidth, 100);
    [_mainScrollView addSubview:_introduceScrollView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _screenWidth-20, 30)];
    _titleLabel.font = [UIFont systemFontOfSize:17];
    [_introduceScrollView addSubview:_titleLabel];
    
    _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, _screenWidth-20, 20)];
    _typeLabel.font = [UIFont systemFontOfSize:15];
    _typeLabel.textColor = [UIColor grayColor];
    [_introduceScrollView addSubview:_typeLabel];
    
    _schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, _screenWidth-20, 20)];
    _schoolLabel.textColor = [UIColor grayColor];
    _schoolLabel.font = [UIFont systemFontOfSize:15];
    [_introduceScrollView addSubview:_schoolLabel];
    
    _teachLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, _screenWidth-20, 20)];
    [_teachLabel setTextColor:[UIColor grayColor]];
    _teachLabel.font = [UIFont systemFontOfSize:15];
    [_introduceScrollView addSubview:_teachLabel];
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.textColor = [UIColor grayColor];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:15];
    [_introduceScrollView addSubview:_descLabel];
}
// 创建目录
- (void)createCourses {
    _courseTableView = [[UITableView alloc] initWithFrame:CGRectMake(_screenWidth, 0, _screenWidth, self.view.frame.size.height-300) style:UITableViewStylePlain];
    _courseTableView.dataSource = self;
    _courseTableView.delegate = self;
    _courseTableView.separatorStyle = UITableViewCellSelectionStyleGray;
    [_mainScrollView addSubview:_courseTableView];
    
    // 头部视图
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 50)];
    _courseTableView.tableHeaderView = headerView;
    UILabel *translatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, _screenWidth-20, 20)];
    translatedLabel.text = @"已翻译";
    translatedLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:translatedLabel];
    
    // 底部视图
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 50)];
    _courseTableView.tableFooterView = footerView;
    UILabel *translatedAllLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, _screenWidth-20, 20)];
    translatedAllLabel.text = @"全部翻译完成";
    translatedAllLabel.font = [UIFont systemFontOfSize:16];
    [footerView addSubview:translatedAllLabel];
}
// 创建推荐数据
- (void)createRecomment {
    _recommentTableView = [[UITableView alloc] initWithFrame:CGRectMake(_screenWidth*2, 0, _screenWidth, self.view.frame.size.height-300) style:UITableViewStylePlain];
    _recommentTableView.dataSource = self;
    _recommentTableView.delegate = self;
    _recommentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_mainScrollView addSubview:_recommentTableView];
}
// 创建更贴评论视图
- (void)createComment {
    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(_screenWidth*3, 0, _screenWidth, self.view.frame.size.height-300) style:UITableViewStyleGrouped];
    _commentTableView.dataSource = self;
    _commentTableView.delegate = self;
    _commentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _commentTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self getCommentWithCommentId:_courseList[_playIndex][@"commentid"]];
    }];
    [_mainScrollView addSubview:_commentTableView];
}

#pragma mark - 获取数据
// 获取课程信息
- (void)getDataFromNet {
    // 获取了课程信息
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager getDataWithUrl:[NSString stringWithFormat:COURSEURL,_plid] parameters:nil success:^(id responseObject) {
        _titleLabel.text = responseObject[@"title"];
        _typeLabel.text = [NSString stringWithFormat:@"类型：%@",responseObject[@"type"]];
        _schoolLabel.text = [NSString stringWithFormat:@"学校：%@",responseObject[@"school"]];
        _teachLabel.text = [NSString stringWithFormat:@"讲师：%@",responseObject[@"director"]];
        
        _descLabel.text = [NSString stringWithFormat:@"简介：%@",responseObject[@"description"]];
        CGFloat height = [Helper heightOfString:_descLabel.text font:[UIFont systemFontOfSize:15] width:_screenWidth-20];
        _descLabel.frame = CGRectMake(10, 120, _screenWidth-20, height);
        _introduceScrollView.contentSize = CGSizeMake(_screenWidth, height+120);
        
        _courseList = responseObject[@"videoList"];
        [_courseTableView reloadData];
        
        // 获取评论
        [self getHotCommentWithCommentId:_courseList[0][@"commentid"]];
        
        NSString *tags = responseObject[@"tags"];
        NSArray *tagsArr = [tags componentsSeparatedByString:@","];
        NSMutableString *sqlStr = [NSMutableString stringWithString:@"select * from course"];
        if (tagsArr.count>0) {
            [sqlStr appendString:@" where"];
        }
        for (NSInteger i = 0; i < tagsArr.count; i ++) {
            [sqlStr appendFormat:@" tags like '%%%@%%'",tagsArr[i]];
            if (i != tagsArr.count-1) {
                [sqlStr appendString:@" or"];
            }
        }
        [sqlStr appendString:@" order by hits"];
        SQLManager *sqlManager = [SQLManager manager];
        [sqlManager.database inDatabase:^(FMDatabase *db) {
            FMResultSet *IsFavSet = [db executeQuery:[NSString stringWithFormat:@"select * from fav where plid = '%@'",_plid]];
            if ([IsFavSet next]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_btnOfFav setImage:[UIImage imageNamed:@"ico_course_favorites_already_iphone"] forState:UIControlStateNormal];
                });
            }
            [IsFavSet close];
        }];
        [sqlManager.database inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:sqlStr];
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
                [_recommentList addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_recommentTableView reloadData];
            });
        }];
    } failure:^(NSError *error) {
        UIImageView *noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 200)];
        noDataImageView.image = [UIImage imageNamed:@"ico_no_data_iphone"];
        noDataImageView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:noDataImageView];
    }];
}
// 获取热门评论
- (void)getHotCommentWithCommentId:(NSString *)commentid {
    _commentTableView.contentOffset = CGPointMake(0, 0);
    _star = 0;
    [_hotCommentList removeAllObjects];
    [_normalCommentList removeAllObjects];
    [_commentTableView reloadData];
    
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager getDataWithUrl:[NSString stringWithFormat:HOTCOMMENTURL,commentid] parameters:nil success:^(id responseObject) {
        if ( responseObject[@"hotPosts"] != nil && ![responseObject[@"hotPosts"] isKindOfClass:[NSNull class]] && [responseObject[@"hotPosts"] count] != 0) {
            [_hotCommentList addObjectsFromArray:responseObject[@"hotPosts"]];
        }
        [self getCommentWithCommentId:commentid];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
// 获取评论
- (void)getCommentWithCommentId:(NSString *)conmmentid {
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager getDataWithUrl:[NSString stringWithFormat:COMMENTURL,conmmentid,_star,_star+=10] parameters:nil success:^(id responseObject) {
        if (responseObject[@"newPosts"] != nil && ![responseObject[@"newPosts"] isKindOfClass:[NSNull class]] && [responseObject[@"newPosts"] count] != 0) {
            [_normalCommentList addObjectsFromArray:responseObject[@"newPosts"]];
        }
        // 设置评论的标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 30)];
        titleLabel.text = [NSString stringWithFormat:@"   第%ld集 跟帖(%@)",_playIndex+1,responseObject[@"tcountt"]];
        _commentTableView.tableHeaderView = titleLabel;
        [_btnOfComment setTitle:[NSString stringWithFormat:@"跟帖(%@)",responseObject[@"tcountt"]] forState:UIControlStateNormal];
        [_commentTableView reloadData];
        [_commentTableView.footer endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark -- UITableViewDataSource&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _commentTableView) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _courseTableView) {
        return _courseList.count;
    }else if (tableView == _recommentTableView) {
        return _recommentList.count;
    }else if (tableView == _commentTableView) {
        if (section == 0) {
            return _hotCommentList.count;
        }else {
            return _normalCommentList.count;
        }
    }
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _commentTableView) {
        return section==0?@"热门跟帖":@"最新跟帖";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _recommentTableView) {
        return 100;
    }else if (tableView == _courseTableView) {
        return 50;
    }else if (tableView == _commentTableView) {
        NSDictionary *dic = nil;
        if (indexPath.section == 0) {
            dic = _hotCommentList[indexPath.row];
        }else {
            dic = _normalCommentList[indexPath.row];
        }
        return 35+[Helper heightOfString:dic[@"1"][@"b"] font:[UIFont systemFontOfSize:14] width:_screenWidth-20];
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _commentTableView) {
        return 30;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _courseTableView) {
        static NSString *ReusedID = @"courseID1";
        VideoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedID];
        if (!cell) {
            cell = [[VideoListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReusedID];
        }
        cell.titleLabel.text = [NSString stringWithFormat:@"[第%ld集]%@",indexPath.row+1,_courseList[indexPath.row][@"title"]];
        cell.icoImageView.image = [UIImage imageNamed:@"ico_paly_circle"];
        cell.titleLabel.textColor = [UIColor blackColor];
        if (_playIndex == indexPath.row) {
            cell.icoImageView.image = [UIImage imageNamed:@"ico_playing"];
            cell.titleLabel.textColor = [UIColor colorWithRed:35/255.0 green:129/255.0 blue:67/255.0 alpha:1.0f];
        }
        return cell;
    }else if (tableView == _recommentTableView) {
        static NSString *ReusedID = @"courseID2";
        CourseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedID];
        if (!cell) {
            cell = [[CourseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReusedID];
        }
        NewCourseModel *model = _recommentList[indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
        cell.titLabel.text = model.title;
        cell.tagLabel.text = [NSString stringWithFormat:@"分类：%@",model.tags];
        cell.countLabel.text = [NSString stringWithFormat:@"集数：%@    已译：%@",model.playcount,model.updated_playcount];
        return cell;
    }else if (tableView == _commentTableView) {
        static NSString *ReusedID = @"commentID";
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedID];
        if (!cell) {
            cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReusedID];
        }
        NSDictionary *dic = nil;
        if (indexPath.section == 0) {
            dic = _hotCommentList[indexPath.row];
        }else {
            dic = _normalCommentList[indexPath.row];
        }
        cell.nameLabel.text = dic[@"1"][@"f"];
        cell.timeLabel.text = dic[@"1"][@"t"];
        cell.contentLabel.text = dic[@"1"][@"b"];
        cell.contentLabel.frame = CGRectMake(10, 30, _screenWidth-20, [Helper heightOfString:dic[@"1"][@"b"] font:[UIFont systemFontOfSize:14] width:_screenWidth-20]+5);
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _courseTableView) {
        if (_playIndex != indexPath.row) {
            _playIndex = indexPath.row;
            [_courseTableView reloadData];
            [self getHotCommentWithCommentId:_courseList[indexPath.row][@"commentid"]];
        }
    }else if (tableView == _recommentTableView) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        NewCourseModel *model = _recommentList[indexPath.row];
        detailVC.plid = model.plid;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
#pragma mark - 按钮功能
// 顶部导航切换
- (void)changeIndex:(UIButton *)btn {
    int index = btn.frame.origin.x/(_screenWidth/4);
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorOfBtn.frame = CGRectMake(btn.frame.origin.x, 42, btn.frame.size.width, 3);
        _mainScrollView.contentOffset = CGPointMake(index*_screenWidth, 0);
    } completion:^(BOOL finished) {
        // 判断mainScrollView的位置，滑动到全部课程页面是先从数据库获取数据，如数据库没有数据则从网上获取数据
//        if (index == 1 && _allCourseArr.count == 0) {
//            [_allCourseTableView.header beginRefreshing];
//        }
    }];
}
// 滑动切换导航
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _mainScrollView) {
        return;
    }
    CGPoint point = scrollView.contentOffset;
    CGRect rect = _indicatorOfBtn.frame;
    int index = point.x/_screenWidth;
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorOfBtn.frame = CGRectMake(index*rect.size.width, 42, rect.size.width, 3);
    } completion:^(BOOL finished) {
        // 判断mainScrollView的位置，滑动到全部课程页面是先从数据库获取数据，如数据库没有数据则从网上获取数据
//        if (index == 1 && _allCourseArr.count == 0) {
//            [_allCourseTableView.header beginRefreshing];
//        }
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
// 收藏
- (void)fav:(UIButton *)btn {
    SQLManager *manager = [SQLManager manager];
    [manager.database inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"select * from fav where plid = '%@'",_plid];
        FMResultSet *resultSet = [db executeQuery:sqlStr];
        if (![resultSet next]) {
            [resultSet close];
            // 收藏
            sqlStr = [NSString stringWithFormat:@"insert into fav (plid) values ('%@')",_plid];
            if ([db executeUpdate:sqlStr]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [btn setImage:[UIImage imageNamed:@"ico_course_favorites_already_iphone"] forState:UIControlStateNormal];
                });
            }
        }else {
            [resultSet close];
            // 取消收藏
            sqlStr = [NSString stringWithFormat:@"delete from fav where plid = '%@'",_plid];
            if ([db executeUpdate:sqlStr]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [btn setImage:[UIImage imageNamed:@"ico_course_favorites_iphone"] forState:UIControlStateNormal];
                });
            }
        }
    }];
    
}
// 下载
- (void)down:(UIButton *)btn {
    DownloadViewController *downVC = [[DownloadViewController alloc] init];
    [self.navigationController pushViewController:downVC animated:YES];
//    [self presentViewController:downVC animated:YES completion:nil];
}
// 播放
- (void)play {
    SQLManager *manager = [SQLManager manager];
    [manager.database inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"insert into history (plid,play_index) values ('%@',%ld)",_plid,_playIndex]];
    }];
    MoviePlayerViewController *movieVC = [[MoviePlayerViewController alloc] initWithUrl:_courseList[_playIndex][@"commentid"]];
    [self presentViewController:movieVC animated:YES completion:^{
        
        
    }];
}
#pragma mark - UIWebViewDelegate

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
