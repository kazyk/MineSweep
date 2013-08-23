//
//  ViewController.m
//  MineSweap
//
//  Created by kazuyuki takahashi on 2013/08/23.
//  Copyright (c) 2013 kazuyuki takahashi. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"
#import "BoardView.h"

@interface ViewController ()
@property (nonatomic) Game *game;
@property (nonatomic) BoardView *boardView;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    BoardView *boardView = [[BoardView alloc] init];
    [self.view addSubview:boardView];
    self.boardView = boardView;

    [self setupGame];
}

- (void)setupGame
{
    self.game = [[Game alloc] init];

    self.boardView.board = self.game.board;
    [self.boardView sizeToFit];

    CGRect frame = self.boardView.frame;
    frame.origin.y = CGRectGetMidY(self.view.bounds) - CGRectGetHeight(frame) / 2;
    self.boardView.frame = frame;
}

- (IBAction)reset
{
    [self setupGame];
}

@end