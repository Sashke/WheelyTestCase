//
//  SHKLabel.m
//  MailRuTestCase
//
//  Created by Sashke on 26.10.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKLabel.h"

@implementation SHKLabel

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.numberOfLines == 0) {
        if (self.preferredMaxLayoutWidth != self.frame.size.width) {
            self.preferredMaxLayoutWidth = self.frame.size.width;
            [self setNeedsUpdateConstraints];
        }
    }
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    if (self.numberOfLines == 0) {
        size.height += 1;
    }
    return size;
}

@end
