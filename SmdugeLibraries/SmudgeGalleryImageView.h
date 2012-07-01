//
//  StuffGalleryImageView.h
//  StuffNZ
//
//  Created by Hisatomo Umaoka on 17/02/12.
//  Copyright (c) 2012 Smudge Apps Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmudgeGalleryImageView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

#pragma mark - UIGestures
@property (strong, nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;

#pragma mark - IBOutlets
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *myImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *loadFailedLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

#pragma mark - Class Methods
+(SmudgeGalleryImageView *) viewForImageWithRect:(CGRect)newRect;

#pragma mark - Instance Methods
-(void) setImage:(UIImage *)image;
- (void) localInit;
-(void) startLoadingNewImage;
@end
