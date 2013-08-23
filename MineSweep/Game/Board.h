//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>

@class Square;


typedef struct {
    NSInteger x, y;
} BoardPoint;


@interface Board : NSObject

- (instancetype)initWithHorizontalSize:(NSInteger)horizontalSize verticalSize:(NSInteger)verticalSize;

@property (nonatomic, readonly) NSInteger horizontalSize;
@property (nonatomic, readonly) NSInteger verticalSize;

- (Square *)squareAtPoint:(BoardPoint)point;

- (void)openSquareAtPoint:(BoardPoint)point;

- (void)updateCountOfMines;

- (void)enumerate:(void(^)(BoardPoint p))block;

@end
