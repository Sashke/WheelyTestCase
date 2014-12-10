//
//  SHKRequestOperation.h
//  MailRuTestCase
//
//  Created by Sashke on 24.10.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHKRequestOperation : NSOperation

- (id)initWithRequest:(NSURLRequest *)urlRequest;

- (void)setCompletionBlockWithSucess:(void (^)(id recievedData))success
                             failure:(void (^)(NSError *error))failure;

@end
