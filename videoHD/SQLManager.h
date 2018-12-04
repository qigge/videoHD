//
//  SQLManager.h
//  videoHD
//
//  Created by Mr.w on 15/10/31.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SQLManager : NSObject

@property (nonatomic,strong) FMDatabaseQueue *database;

+ (instancetype)manager;

@end
