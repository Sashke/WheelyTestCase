//
//  SHKWheelyObject.h
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHKWheelyStory : NSObject
@property (strong, nonatomic) NSString *storyId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *title;

- (id)initWithStoryId:(NSString *)storyId
                 text:(NSString *)text
                title:(NSString *)title;
@end
