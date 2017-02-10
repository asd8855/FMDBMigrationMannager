//
//  AppDataBase.m
//  FMDBMigrationMannager
//
//  Created by libo on 2017/2/10.
//  Copyright © 2017年 蝉鸣. All rights reserved.
//


/*
 我们常常会在App中使用数据库,但是由于版本迭代问题,数据库的结构可能会发生变更,这时候需要对用户原始数据进行保留。这是一个很正常的需求,有人可能会简单粗暴的把数据库删除,重新创建,把数据重新插进去。如果表很多,里面只有一张表的数据结构发生了变化,这种做法显然太粗暴了。
 处理方法共四步:
 1.把要更改结构的那张表A1改名为 temp1
 2.创建一张当前版本需要的结构的表A1
 3.将tempA1里面的有效数据 迁移到A1中
 4.删除tempA1 
 以上简单的思路数据库就更改完毕了
 这时会出现第二个问题,如果用户的app没有及时更新,错过了好几个版本的数据库更改,以上数据库更改不可能会一步到位了。化简为繁,一步一步的更改数据库表结构,直到更改到最后一次.
 */

#import "AppDataBase.h"

typedef NS_ENUM(NSInteger,DBVersion) {

    DBVersionV1,
    DBVersionV2, //历史版本
    DBVersionV3  //当前版本
    
};

static NSString *const DBVersionNum = @"DBVersion";
static NSString *const createTable = @"create table if not exists t1("
"id integer PRIMARY KEY AUTOINCREMENT NOT NULL,"
"name char(50),"
"sex char(4),"
"recordDate TIMESTAMP default (datetime('now', 'localtime')))";

@implementation AppDataBase

+ (NSString *)getDataBasePath {

    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [doc stringByAppendingPathComponent:@"test.db"];
    return path;
}

//获取使用实例
+ (instancetype)shareInstance {

    static AppDataBase *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[super alloc]init];
    });
    return shareInstance;
}

- (instancetype)init {

    if (self = [super init]) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:[AppDataBase getDataBasePath]];
    }
    return self;
}


/*
 需要初始化表结构时,调用此方法
 在这里判断DBVersionNum系统之前是否存储过，
 没有存储说明是第一次安装，则进行首次创建表处理。
 有说明之前数据库存在，进行数据库表结构更改。如果是v1版本的数据库 先从v1升级到v2，在从v2升级到v3，以此类推
 */
- (void)newDBVersionInit {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:DBVersionNum]) {
        //系统之前没有数据库 新建立表
        [self createTables];
    }else {
        DBVersion versionNum = [[[NSUserDefaults standardUserDefaults] objectForKey:DBVersionNum] integerValue];
        switch (versionNum) {
            case DBVersionV1:{
                [self V1ToV2];
            }
            case DBVersionV2:{
                [self V2ToV3];
            }
            case DBVersionV3: {
            
            }
                break;
            default:
                break;
        }
    }
}


//创建新表
- (void)createTables {

    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        @try {
            [db executeUpdate:createTable];
        } @catch (NSException *exception) {
            *rollback = YES;
        } @finally {
            
        }
        
    }];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:DBVersionV3] forKey:DBVersionNum];
}

/*
 版本1 向 版本2 数据迁移
 */
- (void)V1ToV2 {

    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        @try {
            //将原始表名T1 修改为 tempT1
            NSString *renameString = @"alter table t1 rename to tempT1";
            [db executeUpdate:renameString];
            
            //创建新表T1(V2版本的新表创建)
            [db executeUpdate:createTable];
            
            //迁移数据
            NSString *toString = @"insert into t1(name,sex) select name,sex from tempT1";
            [db executeUpdate:toString];
            
            //删除tempT1临时表
            NSString *dropTableStr1 = @"drop table tempT1";
            [db executeUpdate:dropTableStr1];
        } @catch (NSException *exception) {
            *rollback = YES;
        } @finally {
            
        }
        
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:DBVersionV2] forKey:DBVersionNum];
}


- (void)V2ToV3 {
[_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
   
    //和V1ToV2流程一样
}];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:DBVersionV3] forKey:DBVersionNum];
}

@end
