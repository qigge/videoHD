//
//  CommentTableViewCell.m
//  videoHD
//
//  Created by qianfeng on 15/11/2.
//  Copyright © 2015年 qigge. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width*0.6, 20)];
        self.nameLabel.textColor = [UIColor grayColor];
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.nameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-80, 5, 130, 20)];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.timeLabel];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.frame.size.width-20, 10)];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
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
