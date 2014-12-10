//
//  SHKRequestOperation.m
//  MailRuTestCase
//
//  Created by Sashke on 24.10.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKRequestOperation.h"
#import "SHKResponseSerializer.h"
#import "SHKUserInfoFactory.h"

@interface SHKRequestOperation() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *recievedData;
@property (nonatomic, strong) id serializedData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isConcurrent;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) NSPort *port;
@end


@implementation SHKRequestOperation

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    if (self == [super init]) {
        _request = urlRequest;
    }
    return self;
}

- (void)start {
    self.isExecuting = YES;
    self.isConcurrent = YES;
    self.isFinished = NO;
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                      delegate:self
                                              startImmediately:NO];
    self.port = [NSPort port];
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addPort:self.port forMode:NSDefaultRunLoopMode];
    [self.connection scheduleInRunLoop:currentRunLoop forMode:NSDefaultRunLoopMode];
    [self.connection start];
    [currentRunLoop run];
}

- (void)finish {
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop removePort:self.port forMode:NSDefaultRunLoopMode];
}

#pragma mark - NSOperation

-(void)cancel {
    [super cancel];
    [self finish];
    [self.connection cancel];
    self.isFinished = YES;
    self.isExecuting = NO;
}


- (void)setCompletionBlockWithSucess:(void (^)(id))success
                             failure:(void (^)(NSError *))failure {
    __weak SHKRequestOperation *weakSelf = self;
    self.completionBlock = ^{
        if (weakSelf.error) {
            if (failure) {
                failure(weakSelf.error);
            }
        } else {
            if (success) {
                success(weakSelf.serializedData);
            }
        }
    };
}

- (void)setIsExecuting:(BOOL)isExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}


- (void)setIsFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NSURLConnectionDelegate 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.recievedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.recievedData appendData:data];
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.serializer == SHKJsonSerializer) {
        self.serializedData = [SHKResponseSerializer jsonObjectForData:self.recievedData];
        if (self.serializedData) {
            NSArray *errors = [self.serializedData objectForKey:@"errors"];
            if (errors.count > 0) {
                NSDictionary *errorDictionary = errors[0];
                NSInteger errorCode = [[errorDictionary objectForKey:@"code"] integerValue];
                NSDictionary *userInfo = [SHKUserInfoFactory userInfoForStatusCode:errorCode];
                NSError *error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                            code:errorCode
                                                        userInfo:userInfo];
                self.error = error;
            }
        }
    } else {
        self.serializedData = [SHKResponseSerializer imageForData:self.recievedData];
    }
    [self finish];
    self.connection = nil;
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self finish];
    self.error = error;
    self.connection = nil;
    self.isExecuting = NO;
    self.isFinished = YES;;
}




@end
