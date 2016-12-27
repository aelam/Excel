//
//  SKCollectionViewTextCell.m
//  Pods
//
//  Created by ryan on 27/12/2016.
//
//

#import "SKCollectionViewTextCell.h"

@implementation SKCollectionViewTextCell

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
