//
//  HeadCollectionReusableView.m
//  videoHD
//
//  Created by Mr.w on 15/10/28.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "HeadCollectionReusableView.h"
#import "IndexViewController.h"
#import "lunboCourseModel.h"
#import "DetailViewController.h"

@implementation HeadCollectionReusableView
{
    UIScrollView *_adScrollView;
    UIPageControl *_pageControl;
    NSTimer *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _adScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _adScrollView.pagingEnabled = YES;
        _adScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_adScrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(frame.size.width-100, frame.size.height-20, 100, 20)];
        _pageControl.currentPage = 0 ;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor] ;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor] ;
        [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged] ;
        [self addSubview:_pageControl] ;
        _timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(changePageWithTimer) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantPast]];
        
    }
    return self;
}
- (void)setDataArr:(NSArray *)dataArr {
    for (UIView *view in _adScrollView.subviews) {
        [view removeFromSuperview];
    }
    // 刷新头部视图的轮播图
    _dataArr = dataArr;
    NSInteger adImageNum = self.dataArr.count+1;
    _adScrollView.contentSize = CGSizeMake(adImageNum*_adScrollView.frame.size.width, _adScrollView.frame.size.height);
    _adScrollView.delegate = self;
    _adScrollView.contentOffset = CGPointMake(_adScrollView.frame.size.width, 0);
    //设置点的数量
    _pageControl.numberOfPages = adImageNum -2;
    
    for (int i = 0; i < adImageNum; i++) {
        
        UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*_adScrollView.frame.size.width, 0,_adScrollView.frame.size.width, _adScrollView.frame.size.height)];
        lunboCourseModel *model = [[lunboCourseModel alloc] init];
        if (i == 0) {
            model = self.dataArr[adImageNum-2];
        }else if (i == adImageNum-1) {
            model = self.dataArr[1];
        }else {
            model = self.dataArr[i];
        }
        [adImageView sd_setImageWithURL:[NSURL URLWithString:model.imageurl] placeholderImage:[UIImage imageNamed:@"pic_default1"]];
        adImageView.userInteractionEnabled = YES;
        [_adScrollView addSubview:adImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [adImageView addGestureRecognizer:tap];
        
        // 标签
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, [Helper widthOfString:model.tag font:[UIFont systemFontOfSize:10] height:20] + 10, 20)];
        tagLabel.text = model.tag;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.font = [UIFont systemFontOfSize:10];
        tagLabel.layer.cornerRadius = 5;
        tagLabel.clipsToBounds = YES;
        tagLabel.backgroundColor = [Helper stringTOColor:model.tagColorBg];
        tagLabel.textColor = [Helper stringTOColor:model.tagColor];
        [adImageView addSubview:tagLabel];
        // 标题
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, _adScrollView.frame.size.width, 20)];
        title.text = model.title;
        title.textColor = [UIColor whiteColor];
        [adImageView addSubview:title];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    int index = (int)view.frame.origin.x/view.frame.size.width;
    
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    lunboCourseModel *model = _dataArr[index];
    if ([model.plid isEqualToString:@""] || model.plid == nil) {
        return;
    }else if (model.plid.length >= 9) {
        model.plid = [model.plid substringToIndex:9];
    }
    detailVC.plid = model.plid;
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nav pushViewController:detailVC animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self roundPopWith:scrollView];
}
// 无限循环方法
- (void)roundPopWith:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < _adScrollView.frame.size.width) {
        _adScrollView.contentOffset = CGPointMake((_dataArr.count-1)*_adScrollView.frame.size.width, 0);
        _pageControl.currentPage = _dataArr.count-1;
    }else if (scrollView.contentOffset.x > _adScrollView.frame.size.width*(_dataArr.count-1)) {
        _adScrollView.contentOffset = CGPointMake(_adScrollView.frame.size.width, 0);
        _pageControl.currentPage = 0;
    }else {
        NSInteger count = scrollView.contentOffset.x/_adScrollView.frame.size.width;
        _pageControl.currentPage = count-1;
    }

}
- (void)changePageWithTimer {
    [UIView animateWithDuration:0.2 animations:^{
        _adScrollView.contentOffset = CGPointMake(_adScrollView.contentOffset.x+_adScrollView.frame.size.width, 0);
    }];
    [self roundPopWith:_adScrollView];
}
- (void)changePage:(UIPageControl *)page {
    _adScrollView.contentOffset = CGPointMake(self.frame.size.width*page.currentPage, 0);
}
- (void)dealloc {
    [_timer setFireDate:[NSDate distantFuture]];
}


@end
