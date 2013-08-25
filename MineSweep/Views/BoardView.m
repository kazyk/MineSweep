//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "BoardView.h"
#import "SquareView.h"
#import "Square.h"

static const CGSize kSquareSize = {40, 40};


@interface BoardView()
@property (nonatomic) NSMutableArray *squareViews;
@end


@implementation BoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _squareViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.board.horizontalSize * kSquareSize.width, self.board.verticalSize * kSquareSize.height);
}

- (void)setBoard:(Board *)board
{
    if (_board == board) {
        return;
    }
    _board = board;

    for (UIView *view in self.squareViews) {
        [view removeFromSuperview];
    }

    [self.board enumerate:^(BoardPoint p) {
        SquareView *view = [[SquareView alloc] initWithFrame:[self frameForSquareAtPoint:p]];
        view.square = [self.board squareAtPoint:p];
        [self addSubview:view];
        [self.squareViews addObject:view];
    }];
}

- (CGRect)frameForSquareAtPoint:(BoardPoint)point
{
    return CGRectMake(point.x * kSquareSize.width, point.y * kSquareSize.height, kSquareSize.width, kSquareSize.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];

    UIView *view = [self hitTest:p withEvent:event];
    if ([view isKindOfClass:[SquareView class]]) {
        SquareView *squareView = (SquareView *)view;
        [self.board openSquareAtPoint:squareView.square.point];
    }

    NSLog(@"%@", self.board);
}

@end