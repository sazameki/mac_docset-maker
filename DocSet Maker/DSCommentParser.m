//
//  DSCommentParser.m
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "DSCommentParser.h"
#import "DSInfoRepository.h"


@implementation DSCommentParser

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        mPath = [path retain];
        
        NSError *error = nil;
        mSource = [[NSString alloc] initWithContentsOfFile:mPath encoding:NSUTF8StringEncoding error:&error];
        if (!mSource) {
            NSLog(@"Error: %@", error);
            [self release];
            return nil;
        }
        
        mPos = 0;
        mLength = [mSource length];
        mClassInfos = [[NSMutableArray array] retain];
        mGlobalInfos = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [mSource release];
    [mPath release];
    [mClassInfos release];
    [mGlobalInfos release];
    [super dealloc];
}

- (BOOL)hasMoreCharacters
{
    return (mPos < mLength);
}

- (unichar)lookAtNextCharacter
{
    if (![self hasMoreCharacters]) {
        [NSException raise:@"Comment Parse Error" format:@"Illegal End of File", nil];
    }
    return [mSource characterAtIndex:mPos];
}

- (unichar)lookAtNextNextCharacter
{
    if (mPos+1 >= mLength) {
        [NSException raise:@"Comment Parse Error" format:@"Illegal End of File", nil];
    }
    return [mSource characterAtIndex:mPos+1];
}

- (unichar)getNextCharacter
{
    if (![self hasMoreCharacters]) {
        [NSException raise:@"Comment Parse Error" format:@"Illegal End of File", nil];
    }
    return [mSource characterAtIndex:mPos++];
}

- (void)skipNextCharacter
{
    if (![self hasMoreCharacters]) {
        [NSException raise:@"Comment Parse Error" format:@"Illegal End of File", nil];
    }
    mPos++;
}

- (void)skipWhiteSpaces
{
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (isspace((int)c)) {
            mPos++;
        } else {
            break;
        }
    }
}

- (void)skipString
{
    unichar startC = [self getNextCharacter];
    while ([self hasMoreCharacters]) {
        unichar endC = [self getNextCharacter];
        if (endC == startC) {
            break;
        }
    }
}

- (void)skipWhiteSpacesAndString
{
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (isspace((int)c)) {
            [self skipWhiteSpaces];
        } else if (c == '\'' || c == '"') {
            [self skipString];
        } else {
            break;
        }
    }
}

- (NSString *)getStringUntilWhiteSpace
{
    unsigned startPos = mPos;
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (isspace((int)c)) {
            break;
        }
        [self skipNextCharacter];
    }
    unsigned length = mPos - startPos;
    return [mSource substringWithRange:NSMakeRange(startPos, length)];
}

- (NSString *)getStringUntilLineEnd
{
    unsigned startPos = mPos;
    while ([self hasMoreCharacters]) {
        unichar c = [self lookAtNextCharacter];
        if (c == '\r' || c == '\n') {
            break;
        }
        [self skipNextCharacter];
    }
    unsigned length = mPos - startPos;
    return [mSource substringWithRange:NSMakeRange(startPos, length)];
}

- (void)parseNormalComment
{
    DSInformation *currentInfo = nil;
    DSInformation *prevInfo = nil;

    unichar startC = [self lookAtNextCharacter];   // Should be '!' if HeaderDoc comment
    if (startC == '!') {
        [self skipNextCharacter];
    }
    
    while ([self hasMoreCharacters]) {
        [self skipWhiteSpaces];
        
        unichar c1 = [self lookAtNextCharacter];
        unichar c2 = [self lookAtNextNextCharacter];

        if (c1 == '*' && c2 == '/') {
            mPos += 2;
            if (startC == '!') {
                DSInformation *lastClassInfo = nil;
                if ([mClassInfos count] > 0) {
                    lastClassInfo = [mClassInfos lastObject];
                }
                if (lastClassInfo && currentInfo != lastClassInfo) {
                    [lastClassInfo addChildInformation:currentInfo];
                } else if (![currentInfo.tagName isEqualToString:@"@class"]) {
                    [mGlobalInfos addObject:currentInfo];
                }
            }
            break;
        }
        
        if (c1 == '@') {
            NSString *tagName = [self getStringUntilWhiteSpace];
            [self skipWhiteSpaces];            
            NSString *line = [self getStringUntilLineEnd];
            
            if (!currentInfo) {
                currentInfo = [[DSInformation alloc] initWithTag:tagName];
                currentInfo.value = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([tagName isEqualToString:@"@class"]) {
                    [mClassInfos addObject:currentInfo];
                }
                
                DSInformation *declaredInInfo = [[DSInformation alloc] initWithTag:@"*declared-in"];
                declaredInInfo.value = mPath;
                [currentInfo addChildInformation:declaredInInfo];
            } else {
                prevInfo = [[[DSInformation alloc] initWithTag:tagName] autorelease];
                prevInfo.value = line;
                [currentInfo addChildInformation:prevInfo];
            }
        } else {
            NSString *line = [self getStringUntilLineEnd];
            if (!prevInfo) {
                prevInfo = [[[DSInformation alloc] initWithTag:@"@discussion"] autorelease];
                if (currentInfo) {
                    [currentInfo addChildInformation:prevInfo];
                }
            }
            if (![prevInfo appendValue:line]) {
                prevInfo = [[[DSInformation alloc] initWithTag:@"@discussion"] autorelease];
                [prevInfo appendValue:line];
                if (currentInfo) {
                    [currentInfo addChildInformation:prevInfo];
                }
            }
        }
    }
}

- (void)parseLineComment
{
    //NSMutableString *comment = [NSMutableString stringWithString:@"//"];
    while ([self hasMoreCharacters]) {
        unichar c = [self getNextCharacter];
        if (c == '\r' || c == '\n') {
            // Currently we just skip line comments
            break;
        }
        //[comment appendFormat:@"%C", c];
    }
}

- (BOOL)parse
{
    @try {
        while ([self hasMoreCharacters]) {
            [self skipWhiteSpacesAndString];
            
            if (![self hasMoreCharacters]) {
                break;
            }

            unichar c1 = [self getNextCharacter];
            if (c1 == '/') {
                unichar c2 = [self getNextCharacter];
                if (c2 == '*') {
                    [self parseNormalComment];
                    // TODO: HeaderDoc用のコメントが取得できた場合は宣言も取得する。
                } else if (c2 == '/') {
                    [self parseLineComment];
                }
            }
        }
    } @catch (NSException *e) {
        NSLog(@"Failed to Parse: %@", mPath);
    } @finally {
        [[DSInfoRepository sharedRepository] addInfos:mClassInfos];
        [[DSInfoRepository sharedRepository] addInfos:mGlobalInfos];
    }
    
    return YES;
}

@end



