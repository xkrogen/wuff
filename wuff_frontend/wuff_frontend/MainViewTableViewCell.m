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

-(void)loadImageWithCreator:(NSNumber*)creatorID {
    
    NSLog(@"attempting to load profile pic");
    HandleRequest *r = [[HandleRequest alloc]initWithSelector:@"handleGetProfilePic:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:creatorID,@"user_id", nil];
    [r createRequestWithType:POST forExtension:@"/user/get_profile_pic" withDictionary:d];
    
}

-(void)handleGetProfilePic:(NSDictionary*)data {
    NSString *imageUrl = [data objectForKey:@"picture_url"];
    
    if(!imageUrl) {
        self.imageView.image = [UIImage imageNamed:@"check.png"];
    }
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];
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
