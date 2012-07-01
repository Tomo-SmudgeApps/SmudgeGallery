//
//  SmudgeGalleryModel.m
//  SmdugeLibraries
//
//  This class is just a container for information to use in SmudgeGalleryView.
//
//  Created by Hisatomo Umaoka on 29/06/12.
//  Copyright (c) 2012 Smudge Apps Ltd. All rights reserved.
//

#import "SmudgeGalleryModel.h"

@implementation SmudgeGalleryModel
@synthesize imageURL;
@synthesize caption;

-(id) init{
    self = [super init];
    
    if(self){
        //Empty string initialization
        self.imageURL = @"";
        self.caption = @"";
    }
    
    return self;
}

@end
