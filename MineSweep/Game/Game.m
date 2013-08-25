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
    }
    return self;
}

@end