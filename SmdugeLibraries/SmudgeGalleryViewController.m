//
//  SmudgeGalleryViewController.m
//  Smudge
//
//  This VC is intended for modal presentation. 
//
//  To use, pass through an array of SmdugeGalleryModel objects with the corresponding 
//  information:
//  imageURL
//  caption
//
//  The rest is taken care for you (Yes. Even the downloads).
//
//  To change the title bar text, please set the galleryName variable to non nil
//
//  Created by Hisatomo Umaoka on 29/06/12.
//  Copyright 2012 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgeGalleryViewController.h"
#import "ImageDownloadOperation.h"
#import "SmudgeGalleryModel.h"

@implementation SmudgeGalleryViewController
@synthesize topBar;
@synthesize captionView;
@synthesize galleryLabel;
@synthesize captionLabel;
@synthesize imageNumberLabel;
@synthesize prevImage, currentImage, nextImage;
@synthesize imageArray, delegate,  galleryName;
@synthesize currentPosition;

#pragma mark - Caption
-(void) updateCaptionAtIndex:(int) imageIndex forOrientation:(UIInterfaceOrientation) orientation{  
    
    SmudgeGalleryModel *model = [imageArray objectAtIndex:imageIndex];
    
    if (model.caption.length == 0) {
        
        captionView.hidden = YES;
        
        return;
    }
    
    captionView.hidden = NO;
    captionLabel.text = model.caption;
    
    CGSize captionSize = [captionLabel sizeThatFits:CGSizeMake(imagescrollView.frame.size.width-10, FLT_MAX)];
    captionLabel.frame = CGRectMake(5, 5,(int)imagescrollView.frame.size.width-10, (int)captionSize.height);
    
    int frameHeight = captionSize.height;
    if (frameHeight > imagescrollView.frame.size.width/2) {
        frameHeight = imagescrollView.frame.size.width/2;
    }
    
    captionLabel.frame = CGRectMake(5, 
                               5, 
                               imagescrollView.frame.size.width-10, 
                               frameHeight);
    
    captionView.frame = CGRectMake(0, 
                                 imagescrollView.frame.size.height-(captionSize.height + 10), 
                                 imagescrollView.frame.size.width, 
                                 frameHeight + 10);
}

-(IBAction)close{
	[self dismissModalViewControllerAnimated:YES];
}

-(void) animateImageOnMainThread:(SmudgeGalleryImageView *)ref{
    ref.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{ref.alpha = 1.0;} completion:^(BOOL finished){[ref.loadingIndicator stopAnimating];}];
    
}

-(void) loadImageAtIndex:(int) imageIndex withImage:(UIImage *) imageToShow{
    if (imageIndex < imageArray.count) {
        initialLoad = NO;
        if (imageToShow != nil) {
            SmudgeGalleryImageView *ref = nil;
            if (imageIndex == currentPosition) {
                ref = currentImage;
            }
            else if(imageIndex == (currentPosition + 1)){
                ref = nextImage;
            }
            else if(imageIndex == (currentPosition - 1)){
                ref = prevImage;
            }
            
            if (ref != nil) {
                ref.image = imageToShow;
                
                [self performSelectorOnMainThread:@selector(animateImageOnMainThread:) withObject:ref waitUntilDone:NO];
            }
        }
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
        isScrolling = YES;
        currentOffset = scrollView.contentOffset.x;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    int imageIndex = (scrollView.contentOffset.x/imagescrollView.frame.size.width);

    if(imageIndex >= 0 && imageIndex < imageArray.count && imageIndex != currentPosition){
        [self updateCaptionAtIndex:imageIndex forOrientation:self.interfaceOrientation];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
            
        int currentIndex = currentPosition;
        
        currentPosition = (scrollView.contentOffset.x/imagescrollView.frame.size.width);
        
        if (currentPosition == currentIndex) {
            return;
        }
        
        imageNumberLabel.text = [NSString stringWithFormat:@"%i of %i", currentPosition + 1, [imageArray count]];
        
        //User scrolled to the right (next)
        if (scrollView.contentOffset.x == currentOffset+imagescrollView.frame.size.width) {		
            [prevImage setImage:currentImage.myImageView.image];
            [currentImage setImage:nextImage.myImageView.image];
            nextImage.image = nil;
            [nextImage startLoadingNewImage];
            
            currentImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            prevImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition - 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            nextImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition + 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            if(currentPosition+1 < imageArray.count){
                
                SmudgeGalleryModel *model = [imageArray objectAtIndex:currentPosition+1];
                
                ImageDownloadOperation *operation = [[ImageDownloadOperation alloc] init];
                operation.imageIndex = currentPosition+1;
                operation.imageURLToLoad = model.imageURL;
                operation.delegate = self;
                
                [imageLoadingQueue addOperation:operation];
            }
            
        }
        //User scrolled to left (previous)
        else if (scrollView.contentOffset.x == currentOffset-imagescrollView.frame.size.width) {            			
            [nextImage setImage:currentImage.myImageView.image];
            [currentImage setImage:prevImage.myImageView.image];
            [prevImage setImage:nil];
            [prevImage startLoadingNewImage];
            
            currentImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            prevImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition - 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            nextImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition + 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            if(currentPosition-1 >= 0){
                
                SmudgeGalleryModel *model = [imageArray objectAtIndex:currentPosition-1];
                
                ImageDownloadOperation *operation = [[ImageDownloadOperation alloc] init];
                operation.imageIndex = currentPosition-1;
                operation.imageURLToLoad = model.imageURL;
                operation.delegate = self;
                
                [imageLoadingQueue addOperation:operation];
            }
            
        }
        //User has scrolled multiple times
        else {
            self.prevImage.image = nil;
            [prevImage startLoadingNewImage];
            
            self.currentImage.image = nil;	
            [currentImage startLoadingNewImage];
            
            nextImage.image = nil;
            [nextImage startLoadingNewImage];
            
            currentImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            prevImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition - 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
            
            nextImage.frame = CGRectMake(imagescrollView.frame.size.width * (currentPosition + 1), 0, imagescrollView.frame.size.width, imagescrollView.frame.size.height);
                        
            for (int i = currentPosition-1; i < currentPosition + 2; i++) {
                if (i >= 0 && i < imageArray.count) {
                    SmudgeGalleryModel *model = [imageArray objectAtIndex:i];
                    
                    ImageDownloadOperation *operation = [[ImageDownloadOperation alloc] init];
                    operation.imageIndex = i;
                    operation.imageURLToLoad = model.imageURL;
                    operation.delegate = self;
                    
                    [imageLoadingQueue addOperation:operation];
                }
            }
            
            imagescrollView.scrollEnabled = YES;
        }
        
        isScrolling = NO;
}

#pragma mark - Notification
-(void) handleChangeGalleryViewState{
	
    if (topBar.alpha > 0.5) {
        [UIView animateWithDuration:0.3 
                         animations:^(void){
                             topBar.alpha = 0.0;
                             captionView.alpha = 0.0;
                         }
         ];
    }
    else{
        [UIView animateWithDuration:0.3 
                         animations:^(void){
                             topBar.alpha = 1.0;
                             captionView.alpha = 1.0;
                         }
         ];
    }
}

#pragma mark - VC Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; 
    
    [self wantsFullScreenLayout];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeGalleryViewState) name:@"changeGalleryViewState" object:nil];
    
    if (galleryName != nil) {
        galleryLabel.text = galleryName;
    }
    
    currentOffset = 0;
	
}

- (void) viewWillAppear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 768;
        height = 1024;
    }
    else{
        width = 320;
        height = 480;
    }
    
    imageNumberLabel.text = [NSString stringWithFormat:@"%i of %i", currentPosition+1, [imageArray count]];

	[imagescrollView addSubview:contentView];
	
    imageLoadingQueue = [[NSOperationQueue alloc] init];
    [imageLoadingQueue setMaxConcurrentOperationCount:3];
    
    initialLoad = YES;
    
    if (imageArray.count > 0) {
        [self performSelector:@selector(startLoadingImages)];
    }

}

-(void) startLoadingImages{
	    
	count = imageArray.count;
    
    if (imageArray.count == 1) {
        galleryLabel.hidden = YES;
        imageNumberLabel.hidden = YES;
    }
    
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		contentView.frame = CGRectMake(0, 0, width*count, height);
        imagescrollView.frame = CGRectMake(0, 0, width, height);
	}
	else {
		contentView.frame = CGRectMake(0, 0, height*count, width);
        imagescrollView.frame = CGRectMake(0, 0, height, width);
	}
	imagescrollView.contentSize = contentView.frame.size;
    [imagescrollView setContentOffset:CGPointMake(currentPosition*imagescrollView.frame.size.width, 0)];
    
    self.currentImage = [SmudgeGalleryImageView viewForImageWithRect:CGRectMake(imagescrollView.frame.size.width * (currentPosition), 
                                                                               0, 
                                                                               imagescrollView.frame.size.width, 
                                                                               imagescrollView.frame.size.height)];
    
	self.prevImage = [SmudgeGalleryImageView viewForImageWithRect:CGRectMake(imagescrollView.frame.size.width * (currentPosition - 1), 
                                                                            0, 
                                                                            imagescrollView.frame.size.width, 
                                                                            imagescrollView.frame.size.height)];
    
	self.nextImage = [SmudgeGalleryImageView viewForImageWithRect:CGRectMake(imagescrollView.frame.size.width * (currentPosition + 1), 
                                                                            0, 
                                                                            imagescrollView.frame.size.width, 
                                                                            imagescrollView.frame.size.height)];
    
    [contentView addSubview:prevImage];
    [contentView addSubview:currentImage];
    [contentView addSubview:nextImage];
    
    SmudgeGalleryModel *model = [imageArray objectAtIndex:currentPosition];
    
    //Start loading the first two images
    ImageDownloadOperation *operation = [[ImageDownloadOperation alloc] init];
    operation.imageIndex = currentPosition;
    operation.imageURLToLoad = model.imageURL;
    operation.delegate = self;
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    
    [imageLoadingQueue addOperation:operation];
    
    if(currentPosition + 1 < imageArray.count){
        SmudgeGalleryModel *model = [imageArray objectAtIndex:currentPosition+1];
        
        ImageDownloadOperation *secondOperation = [[ImageDownloadOperation alloc] init];
        secondOperation.imageIndex = currentPosition+1;
        secondOperation.imageURLToLoad = model.imageURL;
        secondOperation.delegate = self;
        
        [imageLoadingQueue addOperation:secondOperation];
    }
    
    if (currentPosition - 1 >= 0) {
        SmudgeGalleryModel *model = [imageArray objectAtIndex:currentPosition-1];
        
        ImageDownloadOperation *secondOperation = [[ImageDownloadOperation alloc] init];
        secondOperation.imageIndex = currentPosition-1;
        secondOperation.imageURLToLoad = model.imageURL;
        secondOperation.delegate = self;
        
        [imageLoadingQueue addOperation:secondOperation];
    }
    
    [self updateCaptionAtIndex:currentPosition forOrientation:self.interfaceOrientation];
}

#pragma mark - Rotation
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    // Return YES for supported orientations
	return YES;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	imagescrollView.delegate = nil;
	
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		
		self.view.frame = CGRectMake(0, 0, width, height);
        imagescrollView.frame = CGRectMake(imagescrollView.frame.origin.x, 
                                           imagescrollView.frame.origin.y, 
                                           width, 
                                           height);
		contentView.frame = CGRectMake(0, 0, width*count, height);
		imagescrollView.contentSize = contentView.frame.size;
		
        if (!initialLoad) {
            for(SmudgeGalleryImageView *image in contentView .subviews){
                int index = image.frame.origin.x/height;
                [image.myScrollView setZoomScale:1.0 animated:NO];
                
                image.frame = CGRectMake(width * index, 0, width, height);
                image.myScrollView.contentSize = image.myImageView.frame.size;
            }
        }
        
		currentOffset = width * currentPosition;
		imagescrollView.contentOffset = CGPointMake(width * currentPosition, 0);
	}
	else {
		
		self.view.frame = CGRectMake(0, 0, height, width);
        imagescrollView.frame = CGRectMake(imagescrollView.frame.origin.x, 
                                           imagescrollView.frame.origin.y, 
                                           height, 
                                           width);
		contentView.frame = CGRectMake(0, 0, height*count, width);
		imagescrollView.contentSize = contentView.frame.size;
        
        if (!initialLoad) {
            for(SmudgeGalleryImageView *image in contentView.subviews){
                int index = image.frame.origin.x/width;
                [image.myScrollView setZoomScale:1.0 animated:NO];
                
                image.frame = CGRectMake(height * index, 0, height, width);
                image.myScrollView.contentSize = image.myImageView.frame.size;
            }
        }
        
		currentOffset = height * currentPosition;
		imagescrollView.contentOffset = CGPointMake(height * currentPosition, 0);
	}
    
	imagescrollView.delegate = self ;
    
    if(imageArray != nil){
        [self updateCaptionAtIndex:currentPosition forOrientation:self.interfaceOrientation];
    }
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(imageArray != nil){
        [self updateCaptionAtIndex:currentPosition forOrientation:self.interfaceOrientation];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    for (ImageDownloadOperation *op in [imageLoadingQueue operations]) {
        op.delegate = [NSNull null];
    }
    [imageLoadingQueue cancelAllOperations];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setImageNumberLabel:nil];
    [self setCaptionView:nil];
    [self setCaptionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
