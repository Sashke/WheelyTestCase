//
//  SHKWheelyAPIManager.h
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHKWheelyAPIManager <NSObject>
- (void)willStartRefresh;
- (void)storiesDidUpdate;
- (void)refreshDidFailWithError:(NSError *)error;
@end

@interface SHKWheelyAPIManager : NSObject
@property (weak, nonatomic) id<SHKWheelyAPIManager> delegate;
@property (strong, nonatomic) NSArray *stories;

- (void)refresh;
@end
