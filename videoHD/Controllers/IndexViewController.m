//
//  IndexViewController.m
//  videoHD
//
//  Created by Mr.w on 15/10/26.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "IndexViewController.h"
#import "DetailViewController.h"
#import "FavViewController.h"
#import "SearchViewController.h"
#import "HistoryViewController.h"
#import "MyDownloadViewController.h"

#import "Masonry.h"
#import "IndexCollectionViewCell.h"
#import "Index2CollectionViewCell.h"
#import "CourseTableViewCell.h"
#import "HeadCollectionReusableView.h"
#import "SectionCollectionReusableView.h"

#import "CourseModel.h"
#import "NewCourseModel.h"
#import "lunboCourseModel.h"


#define INDEXURL @"http://c.open.163.com/mobile/recommend/v1.do?mt=aphone"
#define RECOMMENDURL @"http://c.open.163.com/opensg/mopensg.do?uuid=41627125-3e43-3498-a448-4658615ba915&ursid=&count=8"
#define ALLCOURSEURL @"http://mobile.open.163.com/movie/2/getPlaysForAndroid.htm"


@interface IndexViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>
{
    CGFloat _screenWidth;
    UIImageView *_indicatorOfBtn;// 顶部按钮下的选中状态
    UIScrollView *_mainScrollView;
    
    NSMutableArray *_dataArr;  // 首页的数据
    NSMutableArray *_allCourseArr; // 全部课程数据
    
    NSArray *_meTitleArr;
    NSArray *_meImageArr;
    
    UICollectionView *_indexCollectionView;
    UIScrollView *_adScrollView;
    UITableView *_allCourseTableView;
    UITableView *_meTableView;
    
    NSInteger _typeIndex;// 用于记住分类下的按钮tag
    NSInteger _preTypeIndex; // 用于记住分类下的上次选中的tag
    
    NSInteger _sourceIndex; // 用于记住来源按钮的tag
    NSInteger _preSourceIndex;
    
    NSInteger _orderIndex;// 用于记住排序的tag
    NSInteger _preOrderIndex;
    
    dispatch_queue_t _globalQueue;//全局队列
}
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _dataArr = [NSMutableArray array];
    _allCourseArr = [NSMutableArray array];
    
    _meTitleArr = [NSArray arrayWithObjects:@"我的收藏",@"我的下载",@"播发记录",@"设置", nil];
    _meImageArr = [NSArray arrayWithObjects:@"ico_my_favorites",@"ico_my_download",@"ico_my_history",@"ico_my_set", nil];

    //  获取数据
    [self getIndexDataFromNet];
    [self getAllCourseFromNet];
    // 创建视图
    [self createIndexView];
    [self createAllCourseView];
    [self createMeView];
}
#pragma mark - 创建视图
// 创建首页视图
- (void)createIndexView {
//    self.view.backgroundColor = [UIColor redColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar_bg88_iphone"] forBarMetrics:UIBarMetricsDefault];
    // 左侧logo
    UIImageView *leftbarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 151, 22)];
    leftbarView.image = [UIImage imageNamed:@"topLogo"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftbarView];
    
    // 右侧的两个按钮  观看历史，搜索
    UIView *rightbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 77, 44)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarView];
    
    UIButton *btnOfHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfHistory.frame = CGRectMake(0, 10, 22, 22);
    [btnOfHistory setImage:[UIImage imageNamed:@"ico_bar_history"] forState:UIControlStateNormal];
    [btnOfHistory setImage:[UIImage imageNamed:@"ico_bar_history_pressed"] forState:UIControlStateHighlighted];
    [btnOfHistory addTarget:self action:@selector(historyBtn:) forControlEvents:UIControlEventTouchUpInside];
    [rightbarView addSubview:btnOfHistory];
    
    UIButton *btnOfSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfSearch.frame = CGRectMake(50, 10, 22, 22);
    [btnOfSearch setImage:[UIImage imageNamed:@"ico_bar_search"] forState:UIControlStateNormal];
    [btnOfSearch setImage:[UIImage imageNamed:@"ico_bar_search_pressed"] forState:UIControlStateHighlighted];
    [btnOfSearch addTarget:self action:@selector(searchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [rightbarView addSubview:btnOfSearch];
    
    // 导航栏下的导航条背景色
    UIImageView *bottomNavBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 45)];
    bottomNavBgView.userInteractionEnabled = YES;
    bottomNavBgView.image = [UIImage imageNamed:@"bottomnav_bg"];
    [self.view addSubview:bottomNavBgView];
    
    CGFloat widthOfNav = _screenWidth/3;
    //
    UIButton *btnOfIndex = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfIndex.frame = CGRectMake(0, 0, widthOfNav, 43);
    [btnOfIndex setTitle:@"首页" forState:UIControlStateNormal];
    [btnOfIndex setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfIndex addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfIndex];
    
    UIButton *btnOfCourse = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfCourse.frame = CGRectMake(widthOfNav, 0, widthOfNav, 45);
    [btnOfCourse setTitle:@"全部课程" forState:UIControlStateNormal];
    [btnOfCourse setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfCourse addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfCourse];
    
    UIButton *btnOfMe = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOfMe.frame = CGRectMake(widthOfNav*2, 0, widthOfNav, 45);
    [btnOfMe setTitle:@"我" forState:UIControlStateNormal];
    [btnOfMe setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnOfMe addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavBgView addSubview:btnOfMe];
    
    _indicatorOfBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, widthOfNav, 3)];
    _indicatorOfBtn.image = [UIImage imageNamed:@"indicator_49x3"];
    [bottomNavBgView addSubview:_indicatorOfBtn];
    
    // 下面的主视图
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, _screenWidth, self.view.frame.size.height-45)];
    _mainScrollView.contentSize = CGSizeMake(3*_screenWidth, self.view.frame.size.height-45);
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _indexCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, self.view.frame.size.height-109) collectionViewLayout:layout];
    _indexCollectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getIndexDataFromNet];
    }];
    _indexCollectionView.backgroundColor = [UIColor whiteColor];
    _indexCollectionView.dataSource = self;
    _indexCollectionView.delegate = self;
    // 复用
    [_indexCollectionView registerClass:[IndexCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_indexCollectionView registerClass:[Index2CollectionViewCell class] forCellWithReuseIdentifier:@"cell2"];
    [_indexCollectionView registerClass:[HeadCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    [_indexCollectionView registerClass:[SectionCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"section"];
//    [_indexCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"foot"];
    [_mainScrollView addSubview:_indexCollectionView];
}
// 创建全部课程视图
- (void)createAllCourseView {
    // 全部课程的tableView
    _allCourseTableView = [[UITableView alloc] initWithFrame:CGRectMake(_screenWidth, 0, _screenWidth, self.view.frame.size.height-109) style:UITableViewStylePlain];
    _allCourseTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _allCourseTableView.dataSource = self;
    _allCourseTableView.delegate = self;
    [_mainScrollView addSubview:_allCourseTableView];
    
    // 全部课程的头部视图的定制
    UIView *headerOfAllCourseTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 300)];
    _allCourseTableView.tableHeaderView = headerOfAllCourseTableView;

    NSInteger index = 10001;
    _typeIndex = index;
    _preTypeIndex = index;
    // 类型
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, _screenWidth, 20)];
    typeLabel.text = @"类型";
    typeLabel.font = [UIFont systemFontOfSize:12];
    typeLabel.textColor = [UIColor grayColor];
    [headerOfAllCourseTableView addSubview:typeLabel];
    NSArray *typeStrArr = [NSArray arrayWithObjects:@"全部",@"纪录片",@"文学",@"艺术",@"哲学",@"历史",@"经济",@"社会",@"法律",@"媒体",@"伦理",@"心理",@"管理",@"技能",@"数学",@"物理",@"化学",@"生物",@"医学",@"环境",@"计算机", nil];
    NSInteger typeNum = typeStrArr.count;
    CGFloat widthOfBtn = (_screenWidth-20)/4;// 按钮宽度
    for (NSInteger i = 0; i < typeNum/4+1; i ++) {
        for (NSInteger j = 0; j < 4 && i*4+j < typeNum; j++) {
            UIButton *typeBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthOfBtn*j+10, i*20+(i+1)*5 +30, [Helper widthOfString:typeStrArr[i*4+j] font:[UIFont systemFontOfSize:14] height:30]+20, 20)];
            typeBtn.tag = index++;
            typeBtn.layer.cornerRadius = 10;
            typeBtn.clipsToBounds = YES;
            [typeBtn setTitle:typeStrArr[i*4+j] forState:UIControlStateNormal];
            typeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [typeBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
            if (typeBtn.tag == 10001) {
                typeBtn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
                [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [headerOfAllCourseTableView addSubview:typeBtn];
        }
    }
    // 来源
    _sourceIndex = index;
    _preTypeIndex = index;
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 190, _screenWidth, 20)];
    sourceLabel.text = @"来源";
    sourceLabel.font = [UIFont systemFontOfSize:12];
    sourceLabel.textColor = [UIColor grayColor];
    [headerOfAllCourseTableView addSubview:sourceLabel];
    NSArray *sourceStrArr = [NSArray arrayWithObjects:@"全部",@"国内",@"国外",@"TED",@"Coursera", nil];
    NSInteger sourceNum = sourceStrArr.count;
    widthOfBtn = (_screenWidth-20)/3;
    for (NSInteger i = 0; i < sourceNum/3+1; i ++) {
        for (NSInteger j = 0; j < 3 && i*3+j < sourceNum; j++) {
            UIButton *typeBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthOfBtn*j+10, i*20+(i+1)*5+210, [Helper widthOfString:sourceStrArr[i*3+j] font:[UIFont systemFontOfSize:14] height:30]+20, 20)];
            typeBtn.tag = index++;
            typeBtn.layer.cornerRadius = 10;
            typeBtn.clipsToBounds = YES;
            [typeBtn setTitle:sourceStrArr[i*3+j] forState:UIControlStateNormal];
            typeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [typeBtn addTarget:self action:@selector(selectSource:) forControlEvents:UIControlEventTouchUpInside];
            if (typeBtn.tag == 10001+typeNum) {
                typeBtn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
                [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [headerOfAllCourseTableView addSubview:typeBtn];
        }
    }
    // 排序
    _orderIndex = index;
    _preOrderIndex = index;
    NSArray *orderStrArr = [NSArray arrayWithObjects:@"按最新",@"按最热", nil];
    NSInteger orderNum = orderStrArr.count;
    widthOfBtn = (_screenWidth-20)/4;
    for (NSInteger j = 0; j < orderNum; j++) {
        UIButton *typeBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthOfBtn*j+10, 280, [Helper widthOfString:orderStrArr[j] font:[UIFont systemFontOfSize:14] height:30]+20, 20)];
        typeBtn.tag = index++;
        typeBtn.layer.cornerRadius = 10;
        typeBtn.clipsToBounds = YES;
        [typeBtn setTitle:orderStrArr[j] forState:UIControlStateNormal];
        typeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeBtn addTarget:self action:@selector(selectOrder:) forControlEvents:UIControlEventTouchUpInside];
        if (typeBtn.tag == 10001+typeNum+sourceNum) {
            typeBtn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
            [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [headerOfAllCourseTableView addSubview:typeBtn];
    }
}
// 创建我的视图
- (void)createMeView {
    _meTableView = [[UITableView alloc] initWithFrame:CGRectMake(_screenWidth*2, 0, _screenWidth, _mainScrollView.frame.size.height) style:UITableViewStylePlain];
    _meTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _meTableView.dataSource = self;
    _meTableView.delegate = self;
    _meTableView.bounces = NO;
    _meTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_mainScrollView addSubview:_meTableView];
    
    // 头部
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth*2, 0, _screenWidth, 90)];
    _meTableView.tableHeaderView = userView;
    
    UIView *userBgView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 60, 60)];
    userBgView.backgroundColor = [UIColor colorWithRed:225/255.0 green:226/255.0 blue:227/255.0 alpha:1.0];
    userBgView.layer.cornerRadius = 30;
    userBgView.clipsToBounds = YES;
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
    myImageView.image = [UIImage imageNamed:@"ico_my_photo"];
    [userBgView addSubview:myImageView];
    [userView addSubview:userBgView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 89, _screenWidth-20, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [userView addSubview:lineView];
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 100, 90)];
    userLabel.text = @"尚未登录";
    [userView addSubview:userLabel];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [loginBtn setTitle:@"立即登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
    loginBtn.frame = CGRectMake(_screenWidth-[Helper widthOfString:@"立即登录" font:[UIFont systemFontOfSize:14] height:30]-30, 30, [Helper widthOfString:@"立即登录" font:[UIFont systemFontOfSize:14] height:30]+20, 30);
    [userView addSubview:loginBtn];
}
#pragma mark - 获取数据
// 获取首页数据  获取首页数据后获取推荐数据加在到首页数据后
- (void)getIndexDataFromNet {
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager getDataWithUrl:INDEXURL parameters:nil success:^(id responseObject) {
        // 获取首页数据
        for (NSDictionary *dic  in responseObject) {
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:dic[@"name"]];
            for (NSDictionary *itemDic in dic[@"vos"]) {
                lunboCourseModel *model = [[lunboCourseModel alloc] init];
                model.plid = itemDic[@"contentId"];
                model.contentUrl = itemDic[@"contentUrl"];
                model.title = itemDic[@"title"];
                model.imageurl = itemDic[@"picUrl"];
                model.tagColor = itemDic[@"tagColor"];
                model.tag = itemDic[@"tag"];
                model.tagColor = itemDic[@"tagColor"];
                model.tagColorBg = itemDic[@"tagColorBg"];
                model.subtitle = itemDic[@"subtitle"];
                model.desc = itemDic[@"description"];
                [arr addObject:model];
            }
            [_dataArr addObject:arr];
        }
        // 获取推荐数据
        [manager getDataWithUrl:RECOMMENDURL parameters:nil success:^(id responseObject) {
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:@"猜你喜欢"];
            for (NSDictionary *dic in responseObject[@"result"]) {
                lunboCourseModel *model = [[lunboCourseModel alloc] init];
                model.plid = dic[@"itemid"];
                model.title = dic[@"iteminfo"][@"title"];
                model.imageurl = dic[@"iteminfo"][@"bigimgurl"];
                [arr addObject:model];
            }
            [_dataArr addObject:arr];
            [_indexCollectionView reloadData];
            [_indexCollectionView.header endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"获取推荐数据失败 error -- %@",error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"获取首页数据失败 error -- %@",error);
    }];
}
// 获取全部课程  并且存入数据库
- (void)getAllCourseFromNet {
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager getDataWithUrl:ALLCOURSEURL parameters:nil success:^(id responseObject) {
        [_allCourseArr removeAllObjects];
        for (NSDictionary *dic in responseObject) {
            NewCourseModel *model = [[NewCourseModel alloc] init];
            model.desc = dic[@"description"];
            model.hits = [NSString stringWithFormat:@"%@",dic[@"hits"]];
            model.imageurl = dic[@"largeimgurl"];
            model.lastTime = [NSString stringWithFormat:@"%@",dic[@"ltime"]];
            model.playcount = [NSString stringWithFormat:@"%@",dic[@"playcount"]];
            model.plid = dic[@"plid"];
            model.updated_playcount = [NSString stringWithFormat:@"%@",dic[@"updated_playcount"]];
            model.subtitle = dic[@"subtitle"];
            model.source = dic[@"source"];
            model.tags = dic[@"tags"];
            model.title = dic[@"title"];
            [_allCourseArr addObject:model];
        }
        [_allCourseTableView reloadData];
        
        SQLManager *sqlManager = [SQLManager manager];
        [sqlManager.database inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:@"create table if not exists temp_course (id integer primary key autoincrement,plid varchar,title varchar,subtitle varchar,desc varchar,imageurl varchar,lastTime varchar,hits varchar,playcount varchar,updated_playcount varchar,tags varchar,source varchar)"];
            NSArray *tempArr = [NSArray arrayWithArray:_allCourseArr];
            for (NewCourseModel *model in tempArr) {
                [db executeUpdate:@"insert into temp_course (plid,title,subtitle,desc,imageurl,lastTime,hits,playcount,updated_playcount,tags,source) values(?,?,?,?,?,?,?,?,?,?,?)",model.plid,model.title,model.subtitle,model.desc,model.imageurl,model.lastTime,model.hits,model.playcount,model.updated_playcount,model.tags,model.source];
            }
            [db executeUpdate:@"drop table course"];
            [db executeUpdate:@"alter table temp_course rename to course"];
        }];
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
}
// 从数据库中获取全部课程
- (void)getAllCourseFromDbWithSqlStr:(NSString *)sqlStr {
    // 创建全局线程，更新数据库
    [_allCourseArr removeAllObjects];
    [_allCourseTableView reloadData];
    _globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(_globalQueue, ^{
        SQLManager *sqlManager = [SQLManager manager];
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
                [_allCourseArr addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_allCourseTableView reloadData];
            });
        }];
    });
    
}
// 按分类查询
- (void)selectType:(UIButton *)btn {
    // 改变类型选中
    _preTypeIndex = _typeIndex;
    _typeIndex = btn.tag;
    UIButton *preBtn = [self.view viewWithTag:_preTypeIndex];
    preBtn.backgroundColor = [UIColor whiteColor];
    [preBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 查询数据
    [self queryCourse];
}
// 按来源查询
- (void)selectSource:(UIButton *)btn {
    // 改变来源选中
    _preSourceIndex = _sourceIndex;
    _sourceIndex = btn.tag;
    UIButton *preBtn = [self.view viewWithTag:_preSourceIndex];
    preBtn.backgroundColor = [UIColor whiteColor];
    [preBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 查询数据
    [self queryCourse];
}
// 排序   最新和最热
- (void)selectOrder:(UIButton *)btn {
    // 改变排序选中
    _preOrderIndex = _orderIndex;
    _orderIndex = btn.tag;
    UIButton *preBtn = [self.view viewWithTag:_preOrderIndex];
    preBtn.backgroundColor = [UIColor whiteColor];
    [preBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:36/255.0 green:110/255.0 blue:63/255.0 alpha:1.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 查询数据
    [self queryCourse];
}
// 根据来源和分类查询数据，并且排序
- (void)queryCourse {
    UIButton *typeBtn = [self.view viewWithTag:_typeIndex];
    UIButton *sourceBtn = [self.view viewWithTag:_sourceIndex];
    UIButton *orderBtn = [self.view viewWithTag:_orderIndex];
    
    NSMutableString *sqlStr = [NSMutableString stringWithString:@"select * from course"];
    if (![typeBtn.titleLabel.text isEqualToString:@"全部"]) {
       [sqlStr appendString:[NSString stringWithFormat:@" where tags LIKE '%%%@%%' ",typeBtn.titleLabel.text]];
        if (![sourceBtn.titleLabel.text isEqualToString:@"全部"]) {
            [sqlStr appendString:[NSString stringWithFormat:@" and source LIKE '%%%@%%'",sourceBtn.titleLabel.text]];
        }
    }else {
        if (![sourceBtn.titleLabel.text isEqualToString:@"全部"]) {
            [sqlStr appendString:[NSString stringWithFormat:@" where source LIKE '%%%@%%'",sourceBtn.titleLabel.text]];
        }
    }
    if ([orderBtn.titleLabel.text isEqualToString:@"按最新"]) {
//        [sqlStr appendString:@" order by lastTime desc"];
    }else if ([orderBtn.titleLabel.text isEqualToString:@"按最热"]) {
        [sqlStr appendString:@" order by hits desc"];
    }
    NSLog(@"%@",sqlStr);
    [self getAllCourseFromDbWithSqlStr:sqlStr];
}

// 顶部导航切换
- (void)changeIndex:(UIButton *)btn {
    int index = btn.frame.origin.x/(_screenWidth/3);
    [UIView animateWithDuration:0.2 animations:^{
        _indicatorOfBtn.frame = CGRectMake(btn.frame.origin.x, 42, btn.frame.size.width, 3);
        _mainScrollView.contentOffset = CGPointMake(index*_screenWidth, 0);
    } completion:^(BOOL finished) {
        // 判断mainScrollView的位置，滑动到全部课程页面是先从数据库获取数据，如数据库没有数据则从网上获取数据
        if (index == 1 && _allCourseArr.count == 0) {
            [_allCourseTableView.header beginRefreshing];
        }
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
        if (index == 1 && _allCourseArr.count == 0) {
            [_allCourseTableView.header beginRefreshing];
        }
    }];
}
// 查看历史播放记录
- (void)historyBtn:(UIButton *)btn {
    HistoryViewController *historyVC = [[HistoryViewController alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}
// 搜索
- (void)searchBtn:(UIButton *)btn {
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark -- UITableViewDataSource&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _allCourseTableView) {
        return _allCourseArr.count;
    }else {
        return _meTitleArr.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _allCourseTableView) {
        return 100;
    }else {
        return 50;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _allCourseTableView) {
        static NSString *ReusedID = @"reusedID";
        CourseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedID];
        if (!cell) {
            cell = [[CourseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReusedID];
        }
        NewCourseModel *model = _allCourseArr[indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
        cell.titLabel.text = model.title;
        cell.tagLabel.text = [NSString stringWithFormat:@"分类：%@",model.tags];
        cell.countLabel.text = [NSString stringWithFormat:@"集数：%@    已译：%@",model.playcount,model.updated_playcount];
        return cell;
    }else {
        static NSString *ReusedID = @"reusedMe";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReusedID];
        }
        cell.imageView.image = [UIImage imageNamed:_meImageArr[indexPath.row]];
        cell.textLabel.text = _meTitleArr[indexPath.row];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _allCourseTableView) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        NewCourseModel *model = _allCourseArr[indexPath.row];
        detailVC.plid = model.plid;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if (tableView == _meTableView) {
        if (indexPath.row == 0) {
            FavViewController *favVC = [[FavViewController alloc] init];
            [self.navigationController pushViewController:favVC animated:YES];
        }else if (indexPath.row == 2) {
            HistoryViewController *historyVC = [[HistoryViewController alloc] init];
            [self.navigationController pushViewController:historyVC animated:YES];
        }else if (indexPath.row == 1) {
            MyDownloadViewController *downVC = [[MyDownloadViewController alloc] init];
            [self.navigationController pushViewController:downVC animated:YES];
        }
    }
}

#pragma mark -UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataArr.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    NSArray *itemsArr = _dataArr[section];
    return itemsArr.count-1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    lunboCourseModel *model = _dataArr[indexPath.section][indexPath.row+1];
    if (indexPath.section == _dataArr.count-1) {
        Index2CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
        cell.titleLabel.text = model.title;
        return cell;
    }else {
        IndexCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default2"]];
        cell.subtitleLabel.text = model.subtitle;
        cell.titleLabel.text = model.title;
        cell.descriptionLabel.text = model.desc;
        return cell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_screenWidth/2-10, 150);
}
// 设置cell的偏移量
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
// 返回段头尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(_screenWidth, 180);
    }
    return CGSizeMake(_screenWidth, 40);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == 0 ) {
            HeadCollectionReusableView *head = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head" forIndexPath:indexPath];
            head.dataArr = [_dataArr firstObject];
            return head;
        }else {
            SectionCollectionReusableView *section = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"section" forIndexPath:indexPath];
            section.titleLabel.text = [_dataArr[indexPath.section] firstObject];
            return section;
        }
    }else {
        return nil;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    lunboCourseModel *model = _dataArr[indexPath.section][indexPath.row+1];
    detailVC.plid = model.plid;
    [self.navigationController pushViewController:detailVC animated:YES];
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
