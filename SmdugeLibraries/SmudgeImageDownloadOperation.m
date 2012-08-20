//
//  SmudgeImageDownloadOperation.m
//  StuffNZ
//
//  Created by Hisatomo Umaoka on 11/04/11.
//  Copyright 2011 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgeImageDownloadOperation.h"
#import "SmudgeImageDLManager.h"

@implementation SmudgeImageDownloadOperation
@synthesize delegate;
@synthesize loadingImage, imageIndex;
@synthesize loadedImage;
@synthesize imageURLToLoad;

-(id) init{
    self = [super init];
    
    if (self) {
        self.loadingImage = YES;
        self.loadedImage = nil;
        executing = YES;
        finished = NO;
        [self addObserver:self forKeyPath:@"loadingImage" options:0 context:nil];
    }
    
    return self;
}

-(BOOL) isConcurrent{
    return YES;
}

-(BOOL) isExecuting{
    return executing;
}

-(BOOL) isFinished{
    return finished;
}

-(void) updateStatusOnMain{
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"loadingImage"];
}

-(void) getImageInTheBackground{
    @autoreleasepool {
        
        if ([[SmudgeImageDLManager sharedManager] imageExists:imageURLToLoad]) {
            self.loadedImage = [[SmudgeImageDLManager sharedManager] getImageForLink:imageURLToLoad];
            
            [self performSelectorOnMainThread:@selector(updateStatusOnMain) withObject:nil waitUntilDone:YES];
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
            
            if (!self.isCancelled) {
                [self performSelectorOnMainThread:@selector(updateStatusOnMain) withObject:nil waitUntilDone:YES];
            }
        }
        
    }
}

-(void) cancel{
    [self removeObserver:self forKeyPath:@"loadingImage"];
}

-(void) start{
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    if (!self.isCancelled) {
        [self willChangeValueForKey:@"isExecuting"];
        [self performSelectorInBackground:@selector(getImageInTheBackground) withObject:nil];
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadingImage"] && loadingImage == NO) {
        if (![delegate isEqual:[NSNull null]]) {
            if ([delegate isKindOfClass:[SmudgeGalleryViewController class]]) {
                [self willChangeValueForKey:@"isFinished"];
                [(SmudgeGalleryViewController *)delegate loadImageAtIndex:imageIndex withImage:loadedImage];
                finished=YES;
                [self didChangeValueForKey:@"isFinished"];
            }
        }
    }
}

-(void) dealloc{
    [self removeObserver:self forKeyPath:@"loadingImage"];
}

@end
