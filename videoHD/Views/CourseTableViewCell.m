//
//  CourseTableViewCell.m
//  videoHD
//
//  Created by Mr.w on 15/10/29.
//  Copyright © 2015年 Qigge. All rights reserved.
//

#import "CourseTableViewCell.h"

@implementation CourseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, width*0.4, 80)];
        [self.contentView addSubview:self.imgView];
        
        self.check_boxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgView.frame.size.width-35, _imgView.frame.size.height-35, 30, 30)];
        self.check_boxImageView.image = [UIImage imageNamed:@"check_box"];
        [self.imgView addSubview:self.check_boxImageView];
        self.check_boxImageView.hidden = YES;
        
        self.titLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgView.frame)+10, 10, width*0.6-30, 40)];
        self.titLabel.font = [UIFont systemFontOfSize:14];
        self.titLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titLabel];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titLabel.frame), CGRectGetMaxY(self.titLabel.frame), CGRectGetWidth(self.titLabel.frame), 20)];
        self.tagLabel.textColor = [UIColor grayColor];
        self.tagLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.tagLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titLabel.frame), CGRectGetMaxY(self.tagLabel.frame), CGRectGetWidth(self.titLabel.frame), CGRectGetHeight(self.tagLabel.frame))];
        self.countLabel.textColor = [UIColor grayColor];
        self.countLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.countLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
