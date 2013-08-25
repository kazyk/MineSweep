//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "Board.h"
#import "Square.h"


BoardPoint BoardPointMake(NSInteger x, NSInteger y)
{
    BoardPoint p = {x, y};
    return p;
}


#define ASSERT_POINT(point) \
    NSParameterAssert(0 <= point.x && point.x < self.horizontalSize); \
    NSParameterAssert(0 <= point.y && point.y < self.verticalSize);


@interface Board()
@property (nonatomic, readonly) NSMutableArray *squares;
@property (nonatomic) NSInteger undefiniteMineCount;
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

        [self enumerate:^(BoardPoint p, BOOL *stop) {
            Square *sq = [[Square alloc] init];
            sq.point = p;
            [_squares addObject:sq];
        }];

        self.undefiniteMineCount = 10;
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

    if (sq.mineState == kMineStateUndifinite) {
        [self resolveUndefiniteMinesWithSafePoint:point];
    }

    sq.opened = YES;
    if (sq.mineState == kMineStateNoMine && sq.countOfNeighborMines == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self enumerateNeighborsOfPoint:point usingBlock:^(BoardPoint p) {
                [self openSquareAtPoint:p];
            }];
        });
    }
}

- (void)replaceSquaresAtPoint:(BoardPoint)p1 withPoint:(BoardPoint)p2
{
    Square *sq1 = [self squareAtPoint:p1];
    Square *sq2 = [self squareAtPoint:p2];

    [self.squares replaceObjectAtIndex:[self squareIndexAtPoint:p2] withObject:sq1];
    [self.squares replaceObjectAtIndex:[self squareIndexAtPoint:p1] withObject:sq2];

    sq1.point = p2;
    sq2.point = p1;
}

- (void)updateCountOfMines
{
    [self enumerate:^(BoardPoint p, BOOL *stop) {
        __block NSInteger count = 0;

        [self enumerateNeighborsOfPoint:p usingBlock:^(BoardPoint pp) {
            if ([self squareAtPoint:pp].mineState == kMineStateHasMine) {
                ++count;
            }
        }];

        [self squareAtPoint:p].countOfNeighborMines = count;
    }];
}

- (void)enumerate:(void(^)(BoardPoint p, BOOL *stop))block
{
    NSParameterAssert(block);

    const NSInteger v = self.verticalSize;
    const NSInteger h = self.horizontalSize;

    BOOL stop = NO;

    for (NSInteger y = 0; y < v; ++y) {
        for (NSInteger x = 0; x < h; ++x) {
            BoardPoint p = {x, y};
            block(p, &stop);

            if (stop) {
                return;
            }
        }
    }
}

- (void)drop
{
    id<BoardDelegate> delegate = self.delegate;
    [delegate boardWillDrop:self];

    //未確定地雷があったら確定させる
    [self resolveUndefiniteMinesWithSafePoint:BoardPointMake(-1, -1)];

    [self checkPerfectDrop];

    ++self.currentTurn;

    const NSInteger h = self.horizontalSize;
    const NSInteger v = self.verticalSize;

    for (NSInteger y = v-2; y >= 0; --y) {
        for (NSInteger x = 0; x < h; ++x) {
            Square *sq = [self squareAtPoint:BoardPointMake(x, y)];
            if (sq.isOpened) {
                continue;
            }

            BoardPoint p = {x, y + 1};
            while (p.y < v && [self squareAtPoint:p].isOpened) {
                p.y++;
            }
            p.y--;
            if (y != p.y) {
                [self replaceSquaresAtPoint:BoardPointMake(x, y) withPoint:p];
            }
        }
    }

    NSMutableArray *newSquares = [[NSMutableArray alloc] initWithCapacity:[self.squares count]];

    [self enumerate:^(BoardPoint p, BOOL *stop) {
        Square *sq = [self squareAtPoint:p];
        if (sq.isOpened) {
            Square *newSq = [[Square alloc] init];
            newSq.point = p;
            newSq.turn = self.currentTurn;
            [newSquares addObject:newSq];
            self.squares[[self squareIndexAtPoint:p]] = newSq;
        }
    }];

    self.undefiniteMineCount += MIN((NSInteger)[newSquares count]/2, 10);

    [delegate boardDidDrop:self newSquares:newSquares];

    //ラインそろったら消す
    BOOL lineErased = NO;
    for (NSInteger y = 0; y < v; ++y) {
        BOOL allHasMine = YES;
        for (NSInteger x = 0; x < h; ++x) {
            if ([self squareAtPoint:BoardPointMake(x, y)].mineState != kMineStateHasMine) {
                allHasMine = NO;
                break;
            }
        }
        if (allHasMine) {
            for (NSInteger x = 0; x < h; ++x) {
                [self squareAtPoint:BoardPointMake(x, y)].opened = YES;
            }
            lineErased = YES;
        }
    }
    if (lineErased) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 750 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self drop];
        });
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

- (void)checkPerfectDrop
{
    __block BOOL perfect = YES;

    //空いてないsquareが全部地雷だったらPerfectDropになり、
    //squareの色が変わる

    [self enumerate:^(BoardPoint p, BOOL *stop) {
        Square *sq = [self squareAtPoint:p];
        if (!sq.isOpened && sq.mineState != kMineStateHasMine) {
            perfect = NO;
            *stop = YES;
        }
    }];

    if (perfect) {
        [self enumerate:^(BoardPoint p, BOOL *stop) {
            Square *sq= [self squareAtPoint:p];
            if (!sq.isOpened) {
                sq.mineDetected = YES;
            }
        }];
    }
}

//不確定状態になっているsquareの地雷状態を固定、
//ただし（できるだけ）pointに地雷が埋められるのを避ける
- (void)resolveUndefiniteMinesWithSafePoint:(BoardPoint)point
{
    NSArray *undefiniteSquares = [self.squares filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Square *square, NSDictionary *bindings) {
        return (square.mineState == kMineStateUndifinite);
    }]];
    const NSUInteger undefiniteCount = [undefiniteSquares count];

    if (undefiniteCount == 0) {
        return;
    }

    srand((unsigned int)time(NULL));

    for (int i = 0; i < self.undefiniteMineCount; ++i) {
        NSUInteger r = (NSUInteger)(rand() % (int)undefiniteCount);
        Square *sq = undefiniteSquares[r];

        //pointに地雷が埋め込まれるのを回避
        if (sq.point.x == point.x && sq.point.y == point.y && undefiniteCount > 1) {
            --i;
            continue;
        }
        sq.mineState = kMineStateHasMine;
    }

    for (Square *sq in undefiniteSquares) {
        if (sq.mineState == kMineStateUndifinite) {
            sq.mineState = kMineStateNoMine;
        }
    }

    [self updateCountOfMines];
    self.undefiniteMineCount = 0;
}

@end