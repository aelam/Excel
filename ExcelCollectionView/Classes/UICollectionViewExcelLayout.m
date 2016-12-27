//
//  UICollectionViewExcelLayout.m
//  Pods
//
//  Created by ryan on 26/12/2016.
//
//

#import "UICollectionViewExcelLayout.h"

 NSString *const SKCollectionElementKindColumnHeader    = @"SKCollectionElementKindColumnHeader";
 NSString *const SKCollectionElementKindRowHeader       = @"SKCollectionElementKindRowHeader";

const NSInteger DRTopLeftColumnHeaderIndex = -1;

#pragma mark - SKCollectionViewTableLayoutInvalidationContext

@interface SKCollectionViewTableLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic, assign) BOOL keepCellsLayoutAttributes;
@property (nonatomic, assign) BOOL keepSupplementaryViewsLayoutAttributes;

@end

@implementation SKCollectionViewTableLayoutInvalidationContext

@end



@interface UICollectionViewExcelLayout ()

@property (nonatomic, assign) CGSize computedContentSize;
@property (nonatomic, strong) NSArray *layoutAttributesForCells;
@property (nonatomic, strong) NSArray *layoutAttributesForSupplementaryViews;


@end

@implementation UICollectionViewExcelLayout

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.stickyRowHeaders = YES;
    self.stickyColumnHeaders = YES;
    self.itemSize = CGSizeMake(100,50);
}


- (BOOL)stickyColumnHeadersInSection:(NSUInteger)section
{
    return self.stickyColumnHeaders;;// && (section == 0);
}

- (BOOL)stickyRowHeadersInSection:(NSUInteger)section
{
    return self.stickyRowHeaders;
}

- (BOOL)stickyColumnOrRowHeadersInAnySection
{
    NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
        if ([self stickyColumnHeadersInSection:sectionIdx] || [self stickyRowHeadersInSection:sectionIdx]) {
            return YES;
        }
    }
    
    
    return NO;
}

- (CGFloat)widthForRowHeaderInSection:(NSUInteger)section
{
    id<UICollectionViewDelegateExcelLayout> delegate = (id<UICollectionViewDelegateExcelLayout>)self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:layout:widthForColumn:)]) {
        return [delegate collectionView:self.collectionView layout:self widthForColumn:section];
    }
    
    return self.itemSize.width;
}

- (CGFloat)heightForColumnHeaderInSection:(NSUInteger)section
{
    if (section == 0) {
        id<UICollectionViewDelegateExcelLayout> delegate = (id<UICollectionViewDelegateExcelLayout>)self.collectionView.delegate;
        if ([delegate respondsToSelector:@selector(collectionView:layout:heightForRow:)]) {
            return [delegate collectionView:self.collectionView layout:self heightForRow:section];
        }
        
        return self.itemSize.height;
    }
    
    return 0;
}

#pragma mark - Public methods

- (NSUInteger)columnNumberForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row;
}

- (NSUInteger)rowNumberForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        return 1;
    }
    return 0;
}

- (NSUInteger)columnNumberForHeaderIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row;
}

- (NSUInteger)rowNumberForHeaderIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        return 1;
    }
    return 0;
}

- (void)invalidateTableLayout
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        _computedContentSize = CGSizeZero;
        _layoutAttributesForCells = nil;
        _layoutAttributesForSupplementaryViews = nil;
        [super invalidateLayout];
    }
    else {
        SKCollectionViewTableLayoutInvalidationContext *context = (SKCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:self.collectionView.bounds];
        context.keepCellsLayoutAttributes = NO;
        context.keepSupplementaryViewsLayoutAttributes = NO;
        [self invalidateLayoutWithContext:context];
    }
}

#pragma mark - Layout invalidation

+ (Class)invalidationContextClass
{
    return [SKCollectionViewTableLayoutInvalidationContext class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    /**
     *  Workaround for floating (sticky) headers under iOS 6.
     *  This is due to custom invalidation contexts are not available under iOS 6.
     */
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 &&
        [self stickyColumnOrRowHeadersInAnySection]) {
        _layoutAttributesForSupplementaryViews = nil;
    }
    
    return YES;
}

- (void)invalidateLayoutWithContext:(SKCollectionViewTableLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    
    if (![(SKCollectionViewTableLayoutInvalidationContext *)context keepCellsLayoutAttributes]) {
        _computedContentSize = CGSizeZero;
        if (_layoutAttributesForCells) {
            _layoutAttributesForCells = nil;
        }
    }
    
    if (![(SKCollectionViewTableLayoutInvalidationContext *)context keepSupplementaryViewsLayoutAttributes]) {
        if (_layoutAttributesForSupplementaryViews) {
            _layoutAttributesForSupplementaryViews = nil;
        }
    }
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    SKCollectionViewTableLayoutInvalidationContext *context = (SKCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    
    context.keepCellsLayoutAttributes = YES;
    context.keepSupplementaryViewsLayoutAttributes = ![self stickyColumnOrRowHeadersInAnySection];
    
    return context;
}

#pragma mark - Layout methods

- (void)prepareLayout
{
    [super prepareLayout];
    
    // pre-build layout attributes if needed
    [self layoutAttributesForCells];
    [self layoutAttributesForSupplementaryViews];
}

- (CGSize)collectionViewContentSize
{
    if (CGSizeEqualToSize(self.computedContentSize, CGSizeZero)) {
        self.computedContentSize = self.collectionView.frame.size;
    }
    
    return self.computedContentSize;
}

- (NSArray *)layoutAttributesForCells
{
    @synchronized(self) {
        if (!_layoutAttributesForCells) {
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; sectionIdx++) {
                NSUInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView
                                                                            numberOfItemsInSection:sectionIdx];
                for (NSUInteger itemIdx = 0; itemIdx < numberOfItemsInSection; itemIdx++) {
                    [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIdx
                                                                                                             inSection:sectionIdx]]];
                }
            }
            _layoutAttributesForCells = [NSArray arrayWithArray:layoutAttributes];
        }
        return _layoutAttributesForCells;
    }
}

- (NSArray *)layoutAttributesForSupplementaryViews
{
    @synchronized(self) {
        if (!_layoutAttributesForSupplementaryViews) {
            id<UICollectionViewDelegateExcelLayout> delegate = (id<UICollectionViewDelegateExcelLayout>)self.collectionView.delegate;

            id<UICollectionViewDataSourceExcelLayout> dataSource = (id<UICollectionViewDataSourceExcelLayout>)self.collectionView.dataSource;

            
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
                
                NSUInteger columnsCount = [dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIdx];
                
                BOOL hasColumnHeader = ([self heightForColumnHeaderInSection:sectionIdx] > 0);
                if (hasColumnHeader) {
                    for (NSUInteger columnIdx = 0; columnIdx < columnsCount; columnIdx++) {
                        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:SKCollectionElementKindColumnHeader
                                                                                         atIndexPath:[NSIndexPath indexPathForItem:columnIdx
                                                                                                                         inSection:sectionIdx]]];
                    }
                }
                
                BOOL hasRowHeader = ([self widthForRowHeaderInSection:sectionIdx] > 0);
                if (hasRowHeader) {
                    NSUInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView
                                                                    numberOfItemsInSection:sectionIdx];
                    NSUInteger rowsCount = ceilf((float)itemsCount / (float)columnsCount);
                    for (NSUInteger rowIdx = 0; rowIdx < rowsCount; rowIdx++) {
                        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:SKCollectionElementKindRowHeader
                                                                                         atIndexPath:[NSIndexPath indexPathForItem:columnsCount + rowIdx
                                                                                                                         inSection:sectionIdx]]];
                    }
                }
                
                if (hasColumnHeader && hasRowHeader) {
                    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:SKCollectionElementKindColumnHeader
                                                                                     atIndexPath:[NSIndexPath indexPathForItem:DRTopLeftColumnHeaderIndex
                                                                                                                     inSection:sectionIdx]]];
                }
            }
            _layoutAttributesForSupplementaryViews = [NSArray arrayWithArray:layoutAttributes];
        }
        return _layoutAttributesForSupplementaryViews;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    [layoutAttributes addObjectsFromArray:[self.layoutAttributesForCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    [layoutAttributes addObjectsFromArray:[self.layoutAttributesForSupplementaryViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    return [NSArray arrayWithArray:layoutAttributes];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    id<UICollectionViewDataSourceExcelLayout> dataSource = (id<UICollectionViewDataSourceExcelLayout>)self.collectionView.dataSource;
    id<UICollectionViewDelegateExcelLayout> delegate = (id<UICollectionViewDelegateExcelLayout>)self.collectionView.delegate;

    // get current column and row indexes
    NSUInteger currentColumn = [self columnNumberForIndexPath:indexPath];
    NSUInteger currentRow = [self rowNumberForIndexPath:indexPath];
    
    // compute x position
    CGFloat x = 0;
    CGFloat rowHeaderWidth = [self widthForRowHeaderInSection:indexPath.section];
    if (rowHeaderWidth > 0) {
        x += rowHeaderWidth + (self.horizontalSpacing / 2.f);
    }
    for (NSUInteger columnIdx = 0; columnIdx < currentColumn; columnIdx++) {
        x += [delegate collectionView:self.collectionView layout:self widthForColumn:columnIdx];
        x += self.horizontalSpacing / 2.f;
    }
    
    // compute y position
    CGFloat y = 0;
    for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
        CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
        if (headerHeight > 0) {
            y += headerHeight + (self.verticalSpacing / 2.f);
        }
        
        NSUInteger lastRowIdx;
        if (sectionIdx < indexPath.section) {
            lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                           numberOfItemsInSection:sectionIdx]
                                                                         inSection:sectionIdx]];
        }
        else {
            lastRowIdx = currentRow;
        }
        
        for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
            y += [delegate collectionView:self.collectionView layout:self heightForRow:sectionIdx];
            y += self.verticalSpacing / 2.f;
        }
    }
    y += (indexPath.section * self.verticalSectionSpacing);
    
    // compute item width
    CGFloat width = [delegate collectionView:self.collectionView layout:self widthForColumn:currentColumn];

    // compute item height
    CGFloat height = [delegate collectionView:self.collectionView layout:self heightForRow:indexPath.section];

    // set attributes frame
    currentItemAttributes.frame = CGRectMake(x, y, width, height);
    
    // update content size width if needed
    if (self.computedContentSize.width < x + width) {
        self.computedContentSize = CGSizeMake(x + width, self.computedContentSize.height);
    }
    
    // update content size height if needed
    if (self.computedContentSize.height < y + height) {
        self.computedContentSize = CGSizeMake(self.computedContentSize.width, y + height);
    }
    
    return currentItemAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    id<UICollectionViewDelegateExcelLayout> delegate = (id<UICollectionViewDelegateExcelLayout>)self.collectionView.delegate;

    
    if ([kind isEqualToString:SKCollectionElementKindColumnHeader]) {
        // get header column index
        NSUInteger currentColumn = [self columnNumberForHeaderIndexPath:indexPath];
        
        // compute height
        CGFloat height = [self heightForColumnHeaderInSection:indexPath.section];
        CGFloat width;
        
        CGFloat x = 0;
        if (indexPath.item == DRTopLeftColumnHeaderIndex) {
            x = 0;
            width = [delegate collectionView:self.collectionView layout:self widthForColumn:indexPath.row];

        } else {
            // compute x position
            CGFloat rowHeaderWidth = [self widthForRowHeaderInSection:indexPath.section];
            if (rowHeaderWidth > 0) {
                x += rowHeaderWidth + (self.horizontalSpacing / 2.f);
            }
            for (NSUInteger columnIdx = 0; columnIdx < currentColumn; columnIdx++) {
                x += [delegate collectionView:self.collectionView layout:self widthForColumn:indexPath.row];
                x += self.horizontalSpacing / 2.f;
            }
            
            // compute width
            
            width = [delegate collectionView:self.collectionView layout:self widthForColumn:indexPath.row];
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx < indexPath.section; sectionIdx++) {
            y += [self heightForColumnHeaderInSection:sectionIdx];
            y += self.verticalSpacing / 2.f;
            
            NSUInteger lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                                      numberOfItemsInSection:sectionIdx]
                                                                                    inSection:sectionIdx]];
            for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                y += [delegate collectionView:self.collectionView layout:self heightForRow:sectionIdx];

                y += self.verticalSpacing / 2.f;
            }
        }
        y += (indexPath.section * self.verticalSectionSpacing);
        
        // stick column header to top edge
        if ([self stickyColumnHeadersInSection:indexPath.section]) {
            CGFloat maxY = 0;
            for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
                CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
                if (headerHeight > 0) {
                    maxY += headerHeight + (self.verticalSpacing / 2.f);
                }
                
                NSUInteger lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIdx] inSection:sectionIdx]];
                
                for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                    maxY += [delegate collectionView:self.collectionView layout:self heightForRow:sectionIdx];
                    maxY += self.verticalSpacing / 2.f;
                }
            }
            maxY += (indexPath.section * self.verticalSectionSpacing);
            maxY -= height + (self.verticalSpacing / 2.f);
            
            CGFloat stickyY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
            if (y < stickyY) {
                y = MIN(maxY, stickyY);
            }
        }
        
        // set attributes frame and zIndex
        currentItemAttributes.frame = CGRectMake(x, y, width, height);
        currentItemAttributes.zIndex = 101;
    }
    else if ([kind isEqualToString:SKCollectionElementKindRowHeader]) {
        
        // x positon
        CGFloat x = 0;
        
        // stick header to left edge
        if ([self stickyRowHeadersInSection:indexPath.section]) {
            CGFloat stickyX = CGRectGetMinX(self.collectionView.bounds) + self.collectionView.contentInset.left;
            if (x < stickyX)
                x = stickyX;
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
            CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
            if (headerHeight > 0) {
                y += headerHeight + (self.verticalSpacing / 2.f);
            }
            
            NSUInteger lastRowIdx;
            if (sectionIdx == indexPath.section) {
                lastRowIdx = [self rowNumberForHeaderIndexPath:indexPath];
            }
            else {
                lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                               numberOfItemsInSection:sectionIdx]
                                                                             inSection:sectionIdx]];
            }
            for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                y += [delegate collectionView:self.collectionView layout:self heightForRow:sectionIdx];
                y += self.verticalSpacing / 2.f;
            }
        }
        y += (indexPath.section * self.verticalSectionSpacing);
        
        // compute width
        CGFloat width = [self widthForRowHeaderInSection:indexPath.section];
        
        // compute height
        CGFloat height = [delegate collectionView:self.collectionView layout:self heightForRow:indexPath.section];
        
        // set attributes frame and zIndex
        currentItemAttributes.frame = CGRectMake(x, y, width, height);
        currentItemAttributes.zIndex = 100;
        NSLog(@"%@", currentItemAttributes);
    }
    
    return currentItemAttributes;
}



@end
