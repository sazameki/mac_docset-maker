//
//  DSInfoRepository.h
//  DocSet Maker
//
//  Created by numata on 09/09/13.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DSInformation;


@interface DSInfoRepository : NSObject {
    NSMutableArray  *mGroupInfos;
}

+ (DSInfoRepository *)sharedRepository;

- (void)clearAllInfos;

- (void)addInfos:(NSArray *)infos;

- (NSArray *)groupInfos;

- (NSArray *)groupNames;
- (NSArray *)sortedGroupNames;
- (DSInformation *)groupInfoForName:(NSString *)groupName;

@end




