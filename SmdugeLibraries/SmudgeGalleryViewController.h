//
//  SmudgegalleryViewController.h
//  Smudge
//
//  Created by Hisatomo Umaoka on 29/06/12.
//  Copyright 2012 Smudge Apps Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmudgeGalleryImageView.h"
#import "SmudgeGalleryModel.h"

@interface SmudgeGalleryViewController : UIViewController <UIScrollViewDelegate>{
	    
    CGFloat currentOffset;
	
	BOOL isScrolling;
    BOOL initialLoad;
        
    NSOperationQueue *imageLoadingQueue;  
    
    int currentPosition;
    int count;

    float width;
    float height;
    
    IBOutlet UIView *contentView;
	IBOutlet UIScrollView *imagescrollView;

}

@property (nonatomic, readwrite) int currentPosition;

@property (nonatomic, strong) NSString *galleryName;
@property (nonatomic, strong) SmudgeGalleryImageView *prevImage;
@property (nonatomic, strong) SmudgeGalleryImageView *currentImage;
@property (nonatomic, strong) SmudgeGalleryImageView *nextImage;

#pragma mark - IBOutlets
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *imageNumberLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *captionView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *captionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *galleryLabel;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, unsafe_unretained) id delegate;

-(void) loadImageAtIndex:(int) imageIndex withImage:(UIImage *) imageToShow;
-(IBAction)close;

@end
