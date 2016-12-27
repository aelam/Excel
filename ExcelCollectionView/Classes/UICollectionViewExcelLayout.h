//
//  UICollectionViewExcelLayout.h
//  Pods
//
//  Created by ryan on 26/12/2016.
//
//
// https://github.com/darrarski/DRCollectionViewTableLayout-iOS.git

#import <UIKit/UIKit.h>


extern NSString *const SKCollectionElementKindColumnHeader;
extern NSString *const SKCollectionElementKindRowHeader;

@protocol UICollectionViewDelegateExcelLayout <UICollectionViewDelegate>

@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout widthForColumn:(NSUInteger)column;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForRow:(NSUInteger)section; // inSection:(NSUInteger)section; // Section 对应一行

@end


@protocol UICollectionViewDataSourceExcelLayout <UICollectionViewDataSource>
@required

//- (NSInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView;
//- (NSInteger)numberOfRowsInCollectionView:(UICollectionView *)dataGridView;

@end


@interface UICollectionViewExcelLayout : UICollectionViewLayout


@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize sectionHeaderReferenceSize;
@property (nonatomic) CGSize rowHeaderReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) BOOL stickyColumnHeaders;
@property (nonatomic) BOOL stickyRowHeaders;

@property (nonatomic, assign) CGFloat horizontalSpacing;

/**
 *  Vertical spacing between cells
 */
@property (nonatomic, assign) CGFloat verticalSpacing;

/**
 *  Vertical spacing between cells
 */
@property (nonatomic, assign) CGFloat verticalSectionSpacing;


@end

//UICollectionViewFlowLayout
