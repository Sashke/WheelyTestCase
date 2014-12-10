//
//  SHKWheelyObject.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKWheelyStory.h"

@implementation SHKWheelyStory

- (id)initWithStoryId:(NSString *)storyId
                 text:(NSString *)text
                title:(NSString *)title {
    if (self == [super init]) {
        _storyId = storyId;
        _text = text;
        _title = title;
    }
    return self;
}

@end
