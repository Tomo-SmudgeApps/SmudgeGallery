//
//  StuffGalleryImageView.m
//  StuffNZ
//
//  Created by Hisatomo Umaoka on 17/02/12.
//  Copyright (c) 2012 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgeGalleryImageView.h"

@implementation SmudgeGalleryImageView
@synthesize singleTapRecognizer, doubleTapRecognizer;
@synthesize myScrollView;
@synthesize myImageView;
@synthesize loadFailedLabel;
@synthesize loadingIndicator;

-(void) startLoadingNewImage{
    [loadingIndicator startAnimating];
}

#pragma mark - Setters
-(void) setImage:(UIImage *)image{
    [myScrollView setZoomScale:myScrollView.minimumZoomScale];
    
    if (image == nil) {
        myImageView.image = nil;
    }
    else{
        myImageView.image = image;
    }
}

#pragma mark - UIScrollViewDelegates
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return myImageView;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{

}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    myImageView.frame = [self centeredFrameForScrollView:scrollView andUIView:myImageView];
}
#pragma mark - UIGesutreRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - UIGestureRecognizer Methods
- (void) singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeGalleryViewState" object:nil];
    }
}

- (void) doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if (myScrollView.zoomScale > myScrollView.minimumZoomScale) {
            [myScrollView setZoomScale:myScrollView.minimumZoomScale animated:YES];
        }
        else {
            [myScrollView setZoomScale:1.5 animated:YES];
        }
    }
}

#pragma mark - Initialization Methods
- (void) localInit{
    [myScrollView setMinimumZoomScale:1.0];
    [myScrollView setMaximumZoomScale:3.0];
    
    loadFailedLabel.hidden = YES;
    
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [singleTapRecognizer setNumberOfTouchesRequired:1];
    [singleTapRecognizer setDelegate:self];
        
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [singleTapRecognizer setNumberOfTouchesRequired:1];
    [doubleTapRecognizer setDelegate:self];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [myScrollView addGestureRecognizer:singleTapRecognizer];
    [myScrollView addGestureRecognizer:doubleTapRecognizer];

    [myImageView setContentMode:UIViewContentModeScaleAspectFit];
}

+(SmudgeGalleryImageView *) viewForImageWithRect:(CGRect)newRect{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SmudgeGalleryImageView" owner:self options:nil];
    SmudgeGalleryImageView *imageView = [nibObjects objectAtIndex:0];
    imageView.frame = newRect;
    
    [imageView localInit];
    
    return imageView;
}

@end
