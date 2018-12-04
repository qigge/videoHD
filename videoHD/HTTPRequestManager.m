//
//  HTTPRequestManger.m
//  videoHD
//
//  Created by Mr.w on 15/10/28.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "HTTPRequestManager.h"

@implementation HTTPRequestManager

+ (instancetype)manager {
    static HTTPRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HTTPRequestManager alloc] init];
    });
    return manager;
}

- (void)getDataWithUrl:(NSString *)url parameters:(id)parameters success:(HTTPSuccess)success failure:(HTTPFailure)failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSError *error = nil;
        NSMutableArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (error) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *retStr = [[NSString alloc] initWithData:responseObject encoding:enc];
            NSData *data = [retStr dataUsingEncoding:NSUTF8StringEncoding];
            resultArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        success(resultArr);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
