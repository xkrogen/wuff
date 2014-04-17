//
//  MainViewTableViewCell.m
//  wuff_frontend
//
//  Created by Darren Tsung on 4/15/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "MainViewTableViewCell.h"

@implementation MainViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 17.5, 55, 20)];
        [self.descriptionLabel setTextAlignment:NSTextAlignmentRight];
        self.descriptionLabel.textColor = [UIColor grayColor];
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        
        [self addSubview:self.descriptionLabel];
        
        //self.statusBar = [[RectUIVew alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.statusBar = [[RectUIVew alloc] initWithFrame:CGRectMake(0, -1, 7, 71)];
        [self addSubview:self.statusBar];
    }
    return self;
}

-(void) setTransparentDisabled
{
    self.descriptionLabel.textColor = [UIColor lightGrayColor];
    self.textLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.textColor = [UIColor grayColor];
    [self.imageView setAlpha:0.4f];
}

-(void) setEnabled
{
    self.descriptionLabel.textColor = [UIColor grayColor];
    self.textLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor blackColor];
    [self.imageView setAlpha:1.0f];
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
