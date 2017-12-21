//
//  PhotoStackView.h
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import <UIKit/UIKit.h>

typedef void(^OperationBlock)();

@class PhotoStackView;

@protocol PhotoStackViewDataSource <NSObject>

@required
- (NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStackView;
- (UIImage *)photoStackView:(PhotoStackView *)photoStackView photoForIndex:(NSUInteger)index;

@end



@protocol PhotoStackViewDelegate <NSObject>

@optional
- (void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index;
- (void)photoStackView:(PhotoStackView *)photoStackView didEndMovingPhotoAtIndex:(NSUInteger)index directionLeft:(BOOL)isLeft;

@end



@interface PhotoStackView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) OperationBlock operationBlock;
@property (weak, nonatomic) id <PhotoStackViewDataSource> dataSource;
@property (weak, nonatomic) id <PhotoStackViewDelegate> delegate;

- (void)reloadData;
- (void)leftMoveAnimation;  // 从左侧滑走
- (void)rightMoveAnimation; // 从右侧滑走

@end


