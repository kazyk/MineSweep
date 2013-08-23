//
//  Created by TAKAHASHI kazuyuki on 2013/08/23.
//


#import "BoardView.h"
#import "Board.h"
#import "SquareView.h"

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
        CGRect frame = CGRectMake(p.x * kSquareSize.width, p.y * kSquareSize.height, kSquareSize.width, kSquareSize.height);
        SquareView *view = [[SquareView alloc] initWithFrame:frame];
        view.point = p;
        view.square = [self.board squareAtPoint:p];
        [self addSubview:view];
        [self.squareViews addObject:view];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];

    UIView *view = [self hitTest:p withEvent:event];
    if ([view isKindOfClass:[SquareView class]]) {
        SquareView *squareView = (SquareView *)view;
        [self.board openSquareAtPoint:squareView.point];
    }

    NSLog(@"%@", self.board);
}

@end