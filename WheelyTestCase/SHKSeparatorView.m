//
//  SHKSeparatorView.m
//  WheelyTestCase
//
//  Created by Налия on 10.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SHKSeparatorView.h"

@implementation SHKSeparatorView


//Так как на ретина экране 1 пиксель превращается в 2, то для создания вью
//идентичного сепарейтору в tableView высоту нужно делить на скейл экрана.
- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.constraints.count == 0) {
        CGFloat height = self.frame.size.height;
        if(height == 1) {
            height = height / [UIScreen mainScreen].scale;
        }
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                height);
    }
    else {
        for(NSLayoutConstraint *constraint in self.constraints) {
            if(constraint.firstAttribute == NSLayoutAttributeHeight && constraint.constant == 1) {
                constraint.constant /=[UIScreen mainScreen].scale;
            }
        }
    }
}

@end
