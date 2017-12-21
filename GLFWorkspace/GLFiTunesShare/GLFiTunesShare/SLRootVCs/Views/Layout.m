//
//  Layout.m
//  CircleLayout
//
//  Created by guolongfei on 2017/8/4.
//  Copyright © 2017年 Olivier Gutknecht. All rights reserved.
//

#import "Layout.h"

#pragma mark 适配
#define kScreen [[UIScreen mainScreen] bounds]
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface Layout ()
{
    NSInteger cellCount;
    float cellWidth; // 宽高比为3:4
    float cellHeight;
}
@end

@implementation Layout


// 一般在该方法中设定一些必要的结构和初始需要的参数等
- (void)prepareLayout {
    [super prepareLayout];
    
    cellCount = [self.collectionView numberOfItemsInSection:0];
    cellWidth = kScreenWidth/3.0;
    cellHeight = 4 * (kScreenWidth/3.0) / 3.0;
}

// 返回collectionView内容的尺寸
- (CGSize)collectionViewContentSize {
    NSInteger rows = (cellCount-3)/3;
    if ((cellCount-3)%3 != 0) {
        rows++;
    }
    rows += 2;
    return CGSizeMake(kScreenWidth, cellHeight * rows);
}

// 返回rect中的所有的元素的布局属性
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0 ; i < cellCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

// 返回对应于indexPath的位置的cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    if (path.row == 0) {
        attributes.frame = CGRectMake(0, 0, 2*cellWidth, 2*cellHeight);
    } else if (path.row == 1) {
        attributes.frame = CGRectMake(2*cellWidth, 0, cellWidth, cellHeight);
    } else if (path.row == 2) {
        attributes.frame = CGRectMake(2*cellWidth, cellWidth*4/3.0, cellWidth, cellHeight);
    } else {
        attributes.frame = CGRectMake((path.row%3)*cellWidth, (path.row/3+1)*cellWidth*4/3.0, cellWidth, cellHeight);
    }
    return attributes;
}

// 当边界发生改变时,是否应该刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}


@end
