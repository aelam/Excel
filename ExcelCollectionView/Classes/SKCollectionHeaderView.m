//
//  SKCollectionHeaderView.m
//  Pods
//
//  Created by ryan on 27/12/2016.
//
//

#import "SKCollectionHeaderView.h"

@implementation SKCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textLabel.text = @"HELLO";
        [self addSubview:self.textLabel];
    }
    
    return self;
}

@end
