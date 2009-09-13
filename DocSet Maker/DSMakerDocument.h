//
//  DSMakerDocument.h
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright Satoshi Numata 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface DSMakerDocument : NSDocument
{
    IBOutlet    NSWindow    *oMainWindow;
    
    NSString    *mDocSetName;
    NSString    *mBundleIdentifier;
    NSString    *mVersionNumber;
    NSString    *mPublisherName;
    NSString    *mPublisherIdentifier;
    NSString    *mCopyright;
    
    NSString    *mRootPath;
}

@property(copy, readwrite) NSString     *rootPath;
@property(copy, readwrite) NSString     *docSetName;
@property(copy, readwrite) NSString     *bundleIdentifier;
@property(copy, readwrite) NSString     *versionNumber;
@property(copy, readwrite) NSString     *publisherName;
@property(copy, readwrite) NSString     *publisherIdentifier;
@property(copy, readwrite) NSString     *copyright;

- (IBAction)referRootPath:(id)sender;
- (IBAction)startBuild:(id)sender;

@end


