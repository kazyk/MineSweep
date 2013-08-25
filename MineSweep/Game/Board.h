//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import <Foundation/Foundation.h>

@class Square;


typedef struct {
    NSInteger x, y;
} BoardPoint;

BoardPoint BoardPointMake(NSInteger x, NSInteger y);


@interface Board : NSObject

- (instancetype)initWithHorizontalSize:(NSInteger)horizontalSize verticalSize:(NSInteger)verticalSize;

@property (nonatomic, readonly) NSInteger horizontalSize;
@property (nonatomic, readonly) NSInteger verticalSize;

- (Square *)squareAtPoint:(BoardPoint)point;

- (void)openSquareAtPoint:(BoardPoint)point;

- (void)replaceSquaresAtPoint:(BoardPoint)p1 withPoint:(BoardPoint)p2;

- (void)updateCountOfMines;

- (void)enumerate:(void(^)(BoardPoint p))block;

- (void)drop;

@end
