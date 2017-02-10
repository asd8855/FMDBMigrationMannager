//
//  AppDataBase.h
//  FMDBMigrationMannager
//
//  Created by libo on 2017/2/10.
//  Copyright © 2017年 蝉鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>


@interface AppDataBase : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end
