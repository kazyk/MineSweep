//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "Square.h"


@implementation Square


- (NSString *)description
{
    if (self.mineState == kMineStateHasMine) {
        return @"x";
    }
    if (self.mineState == kMineStateUndifinite) {
        return @"?";
    }
    if (self.countOfNeighborMines == 0) {
        return @" ";
    }
    return [@(self.countOfNeighborMines) stringValue];
}


@end