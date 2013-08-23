//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "Board.h"
#import "Square.h"

#define ASSERT_POINT(point) \
    NSParameterAssert(0 <= point.x && point.x < self.horizontalSize); \
    NSParameterAssert(0 <= point.y && point.y < self.verticalSize);


@interface Board()
@property (nonatomic, readonly) NSMutableArray *squares;
@end


@implementation Board

- (instancetype)initWithHorizontalSize:(NSInteger)horizontalSize verticalSize:(NSInteger)verticalSize
{
    NSParameterAssert(horizontalSize > 0);
    NSParameterAssert(verticalSize > 0);

    self = [super init];
    if (self) {
        _horizontalSize = horizontalSize;
        _verticalSize = verticalSize;

        const NSUInteger cap = (NSUInteger)(horizontalSize * verticalSize);
        _squares = [[NSMutableArray alloc] initWithCapacity:cap];
        for (NSUInteger i = 0; i < cap; ++i) {
            Square *sq = [[Square alloc] init];
            [_squares addObject:sq];
        }
    }
    return self;
}

- (Square *)squareAtPoint:(BoardPoint)point
{
    ASSERT_POINT(point);
    return self.squares[[self squareIndexAtPoint:point]];
}

- (void)openSquareAtPoint:(BoardPoint)point
{
    ASSERT_POINT(point);

    Square *sq = [self squareAtPoint:point];
    if (sq.opened) {
        return;
    }

    sq.opened = YES;
    if (!sq.hasMine && sq.countOfNeighborMines == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self enumerateNeighborsOfPoint:point usingBlock:^(BoardPoint p) {
                [self openSquareAtPoint:p];
            }];
        });
    }
}

- (void)updateCountOfMines
{
    [self enumerate:^(BoardPoint p) {
        __block NSInteger count = 0;

        [self enumerateNeighborsOfPoint:p usingBlock:^(BoardPoint pp) {
            if ([self squareAtPoint:pp].hasMine) {
                ++count;
            }
        }];

        [self squareAtPoint:p].countOfNeighborMines = count;
    }];
}

- (void)enumerate:(void(^)(BoardPoint p))block
{
    NSParameterAssert(block);

    const NSInteger v = self.verticalSize;
    const NSInteger h = self.horizontalSize;

    for (NSInteger y = 0; y < v; ++y) {
        for (NSInteger x = 0; x < h; ++x) {
            BoardPoint p = {x, y};
            block(p);
        }
    }
}

- (void)enumerateNeighborsOfPoint:(BoardPoint)point usingBlock:(void(^)(BoardPoint p))block
{
    ASSERT_POINT(point);
    NSParameterAssert(block);

    const NSInteger h = self.horizontalSize;
    const NSInteger v = self.verticalSize;

    for (NSInteger x = MAX(point.x - 1, 0); x <= MIN(point.x + 1, h-1); ++x) {
        for (NSInteger y = MAX(point.y - 1, 0); y <= MIN(point.y + 1, v-1); ++y) {
            if (x == point.x && y == point.y) {
                continue;
            }

            BoardPoint p = {x, y};
            block(p);
        }
    }
}


- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendString:@"\n"];

    for (NSInteger y = 0; y < self.verticalSize; ++y) {
        for (NSInteger x = 0; x < self.horizontalSize; ++x) {
            BoardPoint p = {x, y};
            [description appendString:[[self squareAtPoint:p] description]];
            [description appendString:@" "];
        }
        [description appendString:@"\n"];
    }

    return description;
}


#pragma mark - private methods

- (NSUInteger)squareIndexAtPoint:(BoardPoint)point
{
    return (NSUInteger)((point.y * self.horizontalSize) + point.x);
}

@end