//
//  DSMakerDocument.m
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright Satoshi Numata 2009 . All rights reserved.
//

#import "DSMakerDocument.h"
#import "DSCommentParser.h"
#import "DSInfoRepository.h"
#import "DSDocWriter.h"


@implementation DSMakerDocument

@synthesize docSetName = mDocSetName;
@synthesize bundleIdentifier = mBundleIdentifier;
@synthesize versionNumber = mVersionNumber;
@synthesize publisherName = mPublisherName;
@synthesize publisherIdentifier = mPublisherIdentifier;
@synthesize copyright = mCopyright;

- (id)init
{
    self = [super init];
    if (self) {
        self.rootPath = @"";
        self.docSetName = @"";
        self.bundleIdentifier = @"";
        self.versionNumber = @"1.0";
        self.publisherName = @"";
        self.publisherIdentifier = @"";
        self.copyright = @"";
        
        mParseTargets = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [mRootPath release];
    [mDocSetName release];
    [mBundleIdentifier release];
    [mVersionNumber release];
    [mPublisherName release];
    [mPublisherIdentifier release];
    [mCopyright release];

    [mParseTargets release];
    
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"DSMakerDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    if (self.rootPath) {
        [properties setObject:self.rootPath forKey:@"Root Path"];
    }
    
    if (self.docSetName) {
        [properties setObject:self.docSetName forKey:@"DocSet Name"];
    }
    if (self.bundleIdentifier) {
        [properties setObject:self.bundleIdentifier forKey:@"Bundle Identifier"];
    }
    if (self.versionNumber) {
        [properties setObject:self.versionNumber forKey:@"Version Number"];
    }
    if (self.publisherName) {
        [properties setObject:self.publisherName forKey:@"Publisher Name"];
    }
    if (self.publisherIdentifier) {
        [properties setObject:self.publisherIdentifier forKey:@"Publisher Identifier"];
    }
    if (self.copyright) {
        [properties setObject:self.copyright forKey:@"Copyright"];
    }
    
    return [NSPropertyListSerialization dataFromPropertyList:properties format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSPropertyListFormat format;
    NSDictionary *properties = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:NULL];

    NSString *rootPath = [properties objectForKey:@"Root Path"];
    if (rootPath) {
        self.rootPath = rootPath;
    }
    
    NSString *docSetName = [properties objectForKey:@"DocSet Name"];
    if (docSetName) {
        self.docSetName = docSetName;
    }

    NSString *bundleIdentifier = [properties objectForKey:@"Bundle Identifier"];
    if (bundleIdentifier) {
        self.bundleIdentifier = bundleIdentifier;
    }

    NSString *versionNumber = [properties objectForKey:@"Version Number"];
    if (versionNumber) {
        self.versionNumber = versionNumber;
    }

    NSString *publisherName = [properties objectForKey:@"Publisher Name"];
    if (publisherName) {
        self.publisherName = publisherName;
    }

    NSString *publisherIdentifier = [properties objectForKey:@"Publisher Identifier"];
    if (publisherIdentifier) {
        self.publisherIdentifier = publisherIdentifier;
    }

    NSString *copyright = [properties objectForKey:@"Copyright"];
    if (copyright) {
        self.copyright = copyright;
    }
    
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}


#pragma mark -

- (NSString *)rootPath
{
    if ([mRootPath length] == 0) {
        return nil;
    }
    return [mRootPath stringByAbbreviatingWithTildeInPath];
}

- (void)setRootPath:(NSString *)path
{
    [mRootPath release];
    mRootPath = [path copy];
}


#pragma mark -

- (IBAction)referRootPath:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    NSString *basePath = [self.rootPath stringByExpandingTildeInPath];
    if (!basePath) {
        basePath = [@"~" stringByExpandingTildeInPath];
    }
    [openPanel beginSheetForDirectory:basePath
                                 file:nil
                       modalForWindow:oMainWindow
                        modalDelegate:self
                       didEndSelector:@selector(rootReferPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:nil];
}

- (void)rootReferPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
        self.rootPath = [panel filename];
    }
}

- (void)checkParseTargetFileAtPath:(NSString *)path
{
    NSArray *targetExtensions = [NSArray arrayWithObjects:@"h", nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
        return;
    }
    
    if (isDir) {
        NSArray *children = [fileManager directoryContentsAtPath:path];
        for (NSString *childName in children) {
            if ([childName isEqualToString:@"build"]) {
                continue;
            }
            NSString *childPath = [path stringByAppendingPathComponent:childName];

            NSString *extension = [[childPath pathExtension] lowercaseString];
            if ([targetExtensions containsObject:extension]) {
                [mParseTargets addObject:childPath];
            }            
        }
    }
}

- (IBAction)startBuild:(id)sender
{
    [[DSInfoRepository sharedRepository] clearAllInfos];
    [mParseTargets removeAllObjects];
    [self checkParseTargetFileAtPath:[self.rootPath stringByExpandingTildeInPath]];
    
    for (NSString *aPath in mParseTargets) {
        DSCommentParser *parser = [[DSCommentParser alloc] initWithPath:aPath];
        [parser parse];
        [parser release];
    }
    
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    if (self.rootPath) {
        [properties setObject:self.rootPath forKey:@"Root Path"];
    }
    
    if (self.docSetName) {
        [properties setObject:self.docSetName forKey:@"DocSet Name"];
    }
    if (self.bundleIdentifier) {
        [properties setObject:self.bundleIdentifier forKey:@"Bundle Identifier"];
    }
    if (self.versionNumber) {
        [properties setObject:self.versionNumber forKey:@"Version Number"];
    }
    if (self.publisherName) {
        [properties setObject:self.publisherName forKey:@"Publisher Name"];
    }
    if (self.publisherIdentifier) {
        [properties setObject:self.publisherIdentifier forKey:@"Publisher Identifier"];
    }
    if (self.copyright) {
        [properties setObject:self.copyright forKey:@"Copyright"];
    }
    
    
    DSDocWriter *writer = [[DSDocWriter alloc] init];
    [writer writeDocumentAtPath:[@"~/Desktop" stringByExpandingTildeInPath] properties:properties];
    [writer release];
}

@end



