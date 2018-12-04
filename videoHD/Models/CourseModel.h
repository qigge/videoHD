//
//  CourseModel.h
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseModel : NSObject

/** 课程id */
@property (nonatomic,strong) NSString *plid;
/** 标题 */
@property (nonatomic,strong) NSString *title;
/** 副标题 */
@property (nonatomic,strong) NSString *subtitle;
/** 描述 */
@property (nonatomic,strong) NSString *desc;
/** 图片地址 */
@property (nonatomic,strong) NSString *imageurl;

@end
