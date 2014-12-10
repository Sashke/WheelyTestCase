//
//  SHKStoryTableViewCell.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKStoryTableViewCell.h"
#import "SHKLabel.h"

@interface SHKStoryTableViewCell()
@property (weak, nonatomic) IBOutlet SHKLabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet SHKLabel *storyTextLabel;
@end

@implementation SHKStoryTableViewCell

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = title;
        self.storyTitleLabel.text = _title;
    }
}

- (void)setText:(NSString *)text {
    if (_text != text) {
        _text = text;
        self.storyTextLabel.text = _text;
    }
}

@end
