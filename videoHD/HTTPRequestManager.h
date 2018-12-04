//
//  HTTPRequestManger.h
//  videoHD
//
//  Created by Mr.w on 15/10/28.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

// 请求成功的回调
typedef void(^HTTPSuccess)(id responseObject);

// 请求失败的回调
typedef void(^HTTPFailure)(NSError *error);

@interface HTTPRequestManager : NSObject

+ (instancetype)manager;

- (void)getDataWithUrl:(NSString *)url parameters:(id)parameters success:(HTTPSuccess)success failure:(HTTPFailure)failure;

@end
