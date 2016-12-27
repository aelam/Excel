//
//  MSViewController.m
//  ExcelCollectionView
//
//  Created by Ryan Wang on 12/26/2016.
//  Copyright (c) 2016 Ryan Wang. All rights reserved.
//

#import "MSViewController.h"
@import ExcelCollectionView;

@interface MSViewController ()

@end

static NSString *const kSectionHeader = @"sectionheader";
static NSString *const kRowHeader = @"rowheader";
static NSString *const kCellId = @"cell";

@interface MSViewController () <UICollectionViewDataSourceExcelLayout>

@end

@implementation MSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.collectionView registerClass:[SKCollectionViewTextCell class] forCellWithReuseIdentifier:kCellId];
    [self.collectionView registerClass:[SKCollectionHeaderView class] forSupplementaryViewOfKind:SKCollectionElementKindColumnHeader withReuseIdentifier:kSectionHeader];
    [self.collectionView registerClass:[SKCollectionHeaderView class] forSupplementaryViewOfKind:SKCollectionElementKindRowHeader withReuseIdentifier:kRowHeader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 确定列数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

// 确定行数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
      return 20;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKCollectionViewTextCell *cell = (SKCollectionViewTextCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor redColor].CGColor;
    cell.layer.borderWidth = 1;
    
    cell.textLabel.text = [NSString stringWithFormat:@"[%zd:%zd]", indexPath.section, indexPath.row];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SKCollectionHeaderView *headerView = nil;
    if ([kind isEqualToString:SKCollectionElementKindColumnHeader] && indexPath.section == 0) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:SKCollectionElementKindColumnHeader withReuseIdentifier:kSectionHeader forIndexPath:indexPath];
        headerView.textLabel.text = [NSString stringWithFormat:@"C:[%zd:%zd]", indexPath.section, indexPath.row];
        return headerView;
    } else if ([kind isEqualToString:SKCollectionElementKindRowHeader]) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:SKCollectionElementKindRowHeader withReuseIdentifier:kRowHeader forIndexPath:indexPath];
        headerView.textLabel.text = [NSString stringWithFormat:@"R:[%zd:%zd]", indexPath.section, indexPath.row];
        headerView.backgroundColor = [UIColor blackColor];
        headerView.textLabel.textColor = [UIColor whiteColor];
        return headerView;
    }
    
    return nil;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout widthForColumn:(NSUInteger)column {
    return 100;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForRow:(NSUInteger)section {
    return 50;
}

@end
