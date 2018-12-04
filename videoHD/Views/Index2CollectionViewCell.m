//
//  Index2CollectionViewCell.m
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "Index2CollectionViewCell.h"

@implementation Index2CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30)];
        [self.contentView addSubview:self.imgView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}


@end
