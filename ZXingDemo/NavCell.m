//
//  NavCell.m
//  ZXingDemo
//
//  Created by tj  on 13-6-3.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import "NavCell.h"

@implementation NavCell
@synthesize scanBtn,destinationLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
