//
//  SQLManager.m
//  videoHD
//
//  Created by Mr.w on 15/10/31.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "SQLManager.h"

@implementation SQLManager

+ (instancetype)manager {
    static SQLManager *manager;
    @synchronized(self) {
        if (!manager) {
            manager = [[SQLManager alloc] init];
        }
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *dbPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/AllCourse.db"];
        
        self.database = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self.database inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"create table if not exists course (id integer primary key autoincrement,plid varchar,title varchar,subtitle varchar,desc varchar,imageurl varchar,lastTime varchar,hits varchar,playcount varchar,updated_playcount varchar,tags varchar,source varchar)"];
            [db executeUpdate:@"create table if not exists fav (id integer primary key autoincrement,plid varchar)"];
            [db executeUpdate:@"create table if not exists history (id integer primary key autoincrement,plid varchar,play_index int)"];
        }];
        
        NSLog(@"%@",dbPath);
    }
    return self;
}


@end
