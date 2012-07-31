//
//  ImageDownloadOperation.m
//  StuffNZ
//
//  Created by Hisatomo Umaoka on 11/04/11.
//  Copyright 2011 Smudge Apps Ltd. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import "SmudgeImageDLManager.h"

@implementation ImageDownloadOperation
@synthesize delegate;
@synthesize loadingImage, imageIndex;
@synthesize loadedImage;
@synthesize imageURLToLoad;

-(id) init{
    self = [super init];
    
    if (self) {
        self.loadingImage = YES;
        self.loadedImage = nil;
        [self addObserver:self forKeyPath:@"loadingImage" options:0 context:nil];
    }
    
    return self;
}

-(void) getImageInTheBackground{
    @autoreleasepool {
        
        if ([[SmudgeImageDLManager sharedManager] imageExists:imageURLToLoad]) {            
            self.loadedImage = [[SmudgeImageDLManager sharedManager] getImageForLink:imageURLToLoad];
            
            [self setValue:[NSNumber numberWithBool:NO] forKey:@"loadingImage"];
        }
        else{
            
            NSString *filePaths = [SmudgeImageDLManager sharedManager].imagePath;
            
            //get file name
            int pos = [imageURLToLoad rangeOfString:@"/" options:NSBackwardsSearch].location;
            if(pos==NSNotFound)loadingImage = NO;
            NSString *fileName = [imageURLToLoad substringFromIndex:pos+1];
            fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"."];
            NSString *saveLocation = [NSString stringWithFormat:@"%@%@", filePaths, fileName];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLToLoad]];
            
            self.loadedImage = [[SmudgeImageDLManager sharedManager] imageWithData:imageData];
            
            if ([imageURLToLoad rangeOfString:@".png"].location != NSNotFound) {
                if ([UIImagePNGRepresentation(loadedImage) writeToFile:saveLocation atomically:YES]) {
                    ;//File is written fine
                    if (![[SmudgeImageDLManager sharedManager] addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[saveLocation stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]]]) {
                    }
                }
            }
            else{
                if([UIImageJPEGRepresentation(loadedImage, 1.0) writeToFile:saveLocation atomically:YES]){
                    ;//file is written fine
                    if (![[SmudgeImageDLManager sharedManager] addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:[saveLocation stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]]]) {
                    }
                }
            }
            
            [self setValue:[NSNumber numberWithBool:NO] forKey:@"loadingImage"];
        }
        
    }
}

-(void) main{
    [self performSelectorInBackground:@selector(getImageInTheBackground) withObject:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadingImage"] && loadingImage == NO) {
        [(SmudgeGalleryViewController *)delegate loadImageAtIndex:imageIndex withImage:loadedImage];
    }
}

-(void) dealloc{
    [self removeObserver:self forKeyPath:@"loadingImage"];
}

@end