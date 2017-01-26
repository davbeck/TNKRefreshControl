//
//  TNKProgressViewController.m
//  TNKRefreshControl
//
//  Created by David Beck on 8/10/15.
//  Copyright © 2015 David Beck. All rights reserved.
//

#import "TNKProgressViewController.h"

#import <TNKRefreshControl/TNKActivityIndicatorView.h>


@interface TNKProgressViewController ()
{
	BOOL _fade;
}

@property (weak, nonatomic) IBOutlet TNKActivityIndicatorView *progressIndicator;

@end

@implementation TNKProgressViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_fade = YES;
}

- (IBAction)toggleFade:(UISwitch *)sender {
	_fade = sender.on;
}

- (IBAction)toggleAnimating:(UISwitch *)sender {
	if (sender.on) {
		[self.progressIndicator startAnimatingWithFadeInAnimation:_fade completion:nil];
	} else {
		[self.progressIndicator stopAnimatingWithFadeAwayAnimation:_fade completion:nil];
	}
}

- (IBAction)changeProgress:(UISlider *)sender {
	self.progressIndicator.progress = sender.value;
}

@end
