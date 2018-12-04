//
//  IndexCollectionViewCell.m
//  videoHD
//
//  Created by Mr.w on 15/10/28.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "IndexCollectionViewCell.h"

@implementation IndexCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 50)];
        [self.contentView addSubview:self.imgView];
        
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, 20)];
        self.subtitleLabel.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.8];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.textColor = [UIColor whiteColor];
        [self.imgView addSubview:self.subtitleLabel];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, frame.size.width, 20)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.descriptionLabel];
    }
    return self;
}

@end
