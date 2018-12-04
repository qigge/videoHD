//
//  NewCourseModel.h
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "CourseModel.h"

@interface NewCourseModel : CourseModel

/** 最后更新时间 */
@property (nonatomic,strong) NSString *lastTime;
/** 点击量 */
@property (nonatomic,strong) NSString *hits;
/** 总共多少集 */
@property (nonatomic,strong) NSString *playcount;
/** 翻译多少集 */
@property (nonatomic,strong) NSString *updated_playcount;
/** tags */
@property (nonatomic,strong) NSString *tags;
/** 来源 */
@property (nonatomic,strong) NSString *source;
@property (nonatomic,assign) NSInteger playIndex;

@end
