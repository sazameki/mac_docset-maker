//
//  DSCommentParser.h
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSInformation.h"


@interface DSCommentParser : NSObject {
    NSString    *mPath;
    
    unsigned    mPos;
    unsigned    mLength;
    NSString    *mSource;
    
    NSMutableSet    *mInfos;
    
    DSInformation   *mCurrentClassLevelInfo;
    DSInformation   *mLastInfo;
}

- (id)initWithPath:(NSString *)path;

- (BOOL)parse;

@end


