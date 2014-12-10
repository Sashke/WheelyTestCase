//
//  SHKRequestOperation.m
//  MailRuTestCase
//
//  Created by Sashke on 24.10.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKRequestOperation.h"

@interface SHKRequestOperation() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *recievedData;
@property (strong, nonatomic) id serializedData;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSPort *port;
@property (assign, nonatomic) BOOL isExecuting;
@property (assign, nonatomic) BOOL isConcurrent;
@property (assign, nonatomic) BOOL isFinished;
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.connection start];
    [currentRunLoop run];
}

- (void)finish {
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop removePort:self.port forMode:NSDefaultRunLoopMode];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NSOperation

- (void)cancel {
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
    self.serializedData = [NSJSONSerialization JSONObjectWithData:self.recievedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
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
