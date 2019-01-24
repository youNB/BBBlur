//
//  ViewController.m
//  BBBlur
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "ViewController.h"
#import "BBBlur.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *origin_view;

@property (weak, nonatomic) IBOutlet UIImageView *result_view;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)gaussBlur:(UIButton *)sender {
    self.result_view.image = [BBBlur.sharedManager gaussianBlur:self.origin_view.image deep:10];
}

- (IBAction)vImageBlur:(UIButton *)sender {
    self.result_view.image = [BBBlur.sharedManager vImageBlur:self.origin_view.image deep:30];
}

- (IBAction)clear:(UIButton *)sender {
    self.result_view.image = nil;
}

@end
