//
//  SHKStoryDetailViewController.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKStoryDetailViewController.h"
#import "SHKWheelyStory.h"

@interface SHKStoryDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;
@end

@implementation SHKStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *navBarTitle = [NSString stringWithFormat:@"%@%@",
                             [[self.story.title substringToIndex:1] uppercaseString],
                             [self.story.title substringFromIndex:1]];
    self.title = navBarTitle;
    self.storyTitleLabel.text = self.story.title;
    self.storyTextLabel.text = self.story.text;
}

@end
