//
//  ImageDownloadOperation.h
//  StuffNZ
//
//  Created by Hisatomo Umaoka on 11/04/11.
//  Copyright 2011 Smudge Apps Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmudgeGalleryViewController.h"

@interface ImageDownloadOperation : NSOperation
@property (nonatomic, readwrite) BOOL loadingImage;
@property (nonatomic, readwrite) int imageIndex;

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, unsafe_unretained) NSString *imageURLToLoad;

@property (nonatomic, strong) UIImage *loadedImage;

@end
