//
//  Migration.h
//  FMDBMigrationMannager
//
//  Created by libo on 2017/2/9.
//  Copyright © 2017年 蝉鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBMigrationManager.h"

@interface Migration : NSObject<FMDBMigrating>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;

- (instancetype)initWithName:(NSString *)name addVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray; //自定义方法

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

@end
