//
//  SHKJSONParser.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKJSONParser.h"
#import "SHKWheelyStory.h"

@implementation SHKJSONParser

- (NSArray *)parseResponseData:(id)responseData {
    NSMutableArray *mutableStories = [NSMutableArray array];
    NSArray *recievedStories = (NSArray *)responseData;
    for (NSDictionary *jsonStory in recievedStories) {
        SHKWheelyStory *story = [self parseStory:jsonStory];
        [mutableStories addObject:story];
    }
    return [mutableStories copy];
}

- (SHKWheelyStory *)parseStory:(NSDictionary *)jsonStory {
    NSString *storyId = [jsonStory objectForKey:@"id"];
    NSString *text = [jsonStory objectForKey:@"text"];
    NSString *title = [jsonStory objectForKey:@"title"];
    SHKWheelyStory *story = [[SHKWheelyStory alloc] initWithStoryId:storyId
                                                               text:text
                                                              title:title];
    return story;
}

@end
