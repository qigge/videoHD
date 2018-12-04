//
//  lunboCourseModel.h
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "CourseModel.h"

@interface lunboCourseModel : CourseModel

@property (nonatomic,strong) NSString *contentUrl;
/** 标签 */
@property (nonatomic,strong) NSString *tag;
/** 标签颜色 */
@property (nonatomic,strong) NSString *tagColor;
/** 标签背景颜色 */
@property (nonatomic,strong) NSString *tagColorBg;

@end
