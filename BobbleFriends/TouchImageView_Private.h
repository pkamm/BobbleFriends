
#import <UIKit/UIKit.h>
#import "ZoomingImageView.h"

@interface UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj;

@end

@interface ZoomingImageView (Private)

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches;
- (void)updateOriginalTransformForTouches:(NSSet *)touches;

- (void)cacheBeginPointForTouches:(NSSet *)touches;
- (void)removeTouchesFromCache:(NSSet *)touches;

@end
