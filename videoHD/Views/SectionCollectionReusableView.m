//
//  SectionCollectionReusableView.m
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "SectionCollectionReusableView.h"

@implementation SectionCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgeView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        imgeView.image = [ UIImage imageNamed:@"ico_home_play"];
        [self addSubview:imgeView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,  10, frame.size.width-40, 20 )];
        [self addSubview:self.titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, frame.size.height-1, frame.size.width-10, 1)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
    }
    return self;
}

@end
