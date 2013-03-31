//
//  FlipsideViewController.m
//  Sound Board
//
//  Created by Daniel Cervantes on 3/30/13.
//  Copyright (c) 2013 ima. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()
@property (nonatomic, weak) IBOutlet UITextField *endpoint;
@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *soundBoardEndpoint = [defaults objectForKey:@"SoundBoardEndpoint"];

    if (soundBoardEndpoint != nil) {
        [self.endpoint setText:soundBoardEndpoint];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if (self.endpoint.text != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.endpoint.text forKey:@"SoundBoardEndpoint"];
    }
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
