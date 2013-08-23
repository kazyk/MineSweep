//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "Game.h"
#import "Board.h"
#import "Square.h"


@implementation Game

- (instancetype)init
{
    self = [super init];
    if (self) {
        _board = [[Board alloc] initWithHorizontalSize:8 verticalSize:8];

        srand((unsigned int)time(NULL));

        for (int i = 0; i < 10; ++i) {
            int r = rand() % 64;
            BoardPoint p = {r / 8, r % 8};
            [_board squareAtPoint:p].hasMine = YES;
        }

        [_board updateCountOfMines];
    }
    return self;
}

@end