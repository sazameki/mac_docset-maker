//
//  DSInfoRepository.m
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "DSInfoRepository.h"
#import "DSInformation.h"


static DSInfoRepository *_instance = nil;


@implementation DSInfoRepository

+ (DSInfoRepository *)sharedRepository
{
    if (!_instance) {
        _instance = [DSInfoRepository new];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        mGroupInfos = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [mGroupInfos release];
    [super dealloc];
}

- (void)clearAllInfos
{
    [mGroupInfos removeAllObjects];
}

- (NSArray *)groupNames
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DSInformation *aGroupInfo in mGroupInfos) {
        [ret addObject:aGroupInfo.value];
    }
    return ret;
}

- (NSArray *)sortedGroupNames
{
    // Sort specific for Karakuri Framework just now (2009/09/15)
    // TODO: Prepare any kind of setting method for users
    NSArray *priorGroupNames = [NSArray arrayWithObjects:@"Game Foundation", @"Game 2D Graphics", @"Game Audio", @"Game Text Processing", @"Game Controls", @"Game 2D Simulator", @"Game Network", nil];
    
    NSMutableArray *ret = [NSMutableArray array];
    NSMutableArray *groupNames = [NSMutableArray arrayWithArray:[self groupNames]];
    
    for (NSString *aPriorGroupName in priorGroupNames) {
        if ([groupNames containsObject:aPriorGroupName]) {
            [ret addObject:aPriorGroupName];
        }
    }
    
    [groupNames removeObjectsInArray:ret];
    [ret addObjectsFromArray:groupNames];
    
    return ret;
}

- (DSInformation *)groupInfoForName:(NSString *)groupName
{
    DSInformation *ret = nil;
    for (DSInformation *aGroupInfo in mGroupInfos) {
        if ([aGroupInfo.value isEqualToString:groupName]) {
            ret = aGroupInfo;
            break;
        }
    }
    if (!ret) {
        ret = [[DSInformation alloc] initWithTag:@"@group"];
        ret.value = groupName;
        [mGroupInfos addObject:ret];
    }
    return ret;
}

- (void)addInfos:(NSArray *)infos
{
    for (DSInformation *anInfo in infos) {
        NSArray *groups = [anInfo childInfosWithTag:@"@group"];
        DSInformation *theGroupInfo = nil;
        if ([groups count] > 0) {
            DSInformation *groupInfo = [groups objectAtIndex:0];
            theGroupInfo = [self groupInfoForName:groupInfo.value];
        } else {
            theGroupInfo = [self groupInfoForName:@"Global Reference"];
        }
        [theGroupInfo addChildInformation:anInfo];
    }
}

- (NSArray *)groupInfos
{
    return mGroupInfos;
}

@end


