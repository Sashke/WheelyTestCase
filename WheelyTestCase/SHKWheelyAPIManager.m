//
//  SHKWheelyAPIManager.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKWheelyAPIManager.h"
#import "SHKRequestOperation.h"
#import "SHKJSONParser.h"

@interface SHKWheelyAPIManager()
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) SHKJSONParser *parser;
@property (strong, nonatomic) NSTimer *refreshTimer;
@end

NSString * const kAPIEndPoint = @"http://crazy-dev.wheely.com";

@implementation SHKWheelyAPIManager

#pragma mark - Lifecycle

- (id)init {
    if (self == [super init]) {
        _refreshTimer = [self createTimer];
    }
    return self;
}

#pragma mark - Working With Data

//Здесь используется NSURLConnection завернутый в NSOperation т.к. использовать
//AFNetworking для одного запроса сравнимо со стрельбой из танка по воробьям
//Используется именно NSURLConnection потому что не были указаны поддерживаемые версии iOS
//Благодаря использованию NSURLConnection мы получаем поддержу iOS 6,7,8. Для проектов iOS 7+
//я обычно использую AFNetworking с NSURLSessionManager'ом.

//Тоже самое с парсером JSON - в данном случае быстрее было написать свой маленький парсер
//чем встраивать какую-либо библиотеку и писать для нее маппинги

- (void)refresh {
    [self stopTimer];
    [self.delegate willStartRefresh];
    NSURL *url = [NSURL URLWithString:kAPIEndPoint];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    SHKRequestOperation *requestOperation = [[SHKRequestOperation alloc] initWithRequest:request];
    __weak SHKWheelyAPIManager *weakSelf = self;
    
    [requestOperation setCompletionBlockWithSucess:^(id recievedData) {
        NSArray *stories = [weakSelf.parser parseResponseData:recievedData];
        weakSelf.stories = stories;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.refreshTimer = [weakSelf createTimer];
            [weakSelf.delegate storiesDidUpdate];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.refreshTimer = [weakSelf createTimer];
            [weakSelf.delegate refreshDidFailWithError:error];
        });
    }];
    
    [self.operationQueue addOperation:requestOperation];
}

#pragma mark - Timer 

- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:30
                                            target:self
                                          selector:@selector(refresh)
                                          userInfo:nil
                                           repeats:NO];
}

- (void)stopTimer {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

#pragma mark - Custom Getters

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

- (SHKJSONParser *)parser {
    if (!_parser) {
        _parser = [[SHKJSONParser alloc] init];
    }
    return _parser;
}

@end
