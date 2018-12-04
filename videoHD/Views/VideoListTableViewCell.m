//
//  VideoListTableViewCell.m
//  videoHD
//
//  Created by qianfeng on 15/11/2.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "VideoListTableViewCell.h"

@implementation VideoListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _icoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 20, 20)];
        _icoImageView.image = [UIImage imageNamed:@"ico_paly_circle"];
        [self.contentView addSubview:_icoImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, self.contentView.frame.size.width-50, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
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
