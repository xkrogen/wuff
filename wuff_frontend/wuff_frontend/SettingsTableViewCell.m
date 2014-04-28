//
//  SettingsTableViewCell.m
//  wuff_frontend
//
//  Created by Darren Tsung on 4/15/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SettingsTableViewCell.h"

@implementation SettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imggy = [[UIImageView alloc] initWithFrame:CGRectMake(27, 12, 25, 20)];
        [self.contentView addSubview:self.imggy];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
