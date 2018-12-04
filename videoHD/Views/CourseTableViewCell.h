//
//  CourseTableViewCell.h
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseTableViewCell : UITableViewCell

/** 图片 */
@property (nonatomic,strong) UIImageView *imgView;
/** check_box */
@property (nonatomic,strong) UIImageView *check_boxImageView;
/** 标题 */
@property (nonatomic,strong) UILabel *titLabel;
/** 分类 */
@property (nonatomic,strong) UILabel *tagLabel;
/** 集数和更新数 */
@property (nonatomic,strong) UILabel *countLabel;

@end
