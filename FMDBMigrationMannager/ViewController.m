//
//  ViewController.m
//  FMDBMigrationMannager
//
//  Created by libo on 2017/2/9.
//  Copyright © 2017年 蝉鸣. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "Migration.h"
@interface ViewController ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self FMDB];
}

- (void)FMDB {

    //1.获取数据库文件的路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"test.db"];
    NSLog(@"dbPath:%@",fileName);
    //2.获取数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    
    //3.使用如下语句,如果打开失败,可能是权限不足后者资源不足。通常打开操作后,需要调用close 方法来关闭数据库。在和数据库交互之前,数据库必须是打开的。如果资源或权限不足无法打开或创建数据库,都会导致打开失败。
    if ([_db open]) {
        //4.创表
        BOOL result = [_db executeUpdate:@"CREATE TABLE  if not exists book (id integer primary key autoincrement, bookNumber integer, bookName text, authorID integer, pressName text);"];
        if (result) {
            NSLog(@"创建表成功");
        }
        
        if ([self.db columnExists:@"email" inTableWithName:@"book"]) {
            
            NSLog(@"已经存在");
        }else {
            NSString *alertStr = [NSString stringWithFormat:@"alter table book add email text"];
            [self.db executeUpdate:alertStr];
            NSLog(@"不存在");
        }

        
    }
    
    //版本迁移
    /*
     1.将数据库与我们的FMDBMigrationManager关联起来
     fileName是要升级的数据库的地址
     [NSBundle mainBundle]是保存数据库升级文件的位置 根据自己放文件的位置定
     */
//    FMDBMigrationManager *manager = [FMDBMigrationManager managerWithDatabaseAtPath:fileName migrationsBundle:[NSBundle mainBundle]];
//    Migration *migration1 = [[Migration alloc]initWithName:@"新增User表" addVersion:1 andExecuteUpdateArray:@[@"CREATE TABLE  if not exists User (Name text, age integer)"]];
//    
//    Migration *migration2 = [[Migration alloc]initWithName:@"User表新增字段 email" addVersion:2 andExecuteUpdateArray:@[@"alter table User add email text"]];
//    
//    Migration *migration3 = [[Migration alloc]initWithName:@"User表新增字段 phone" addVersion:3 andExecuteUpdateArray:@[@"alter table User add phone text",@"alter table User add sex text"]];
//    
//    [manager addMigration:migration1];
//    [manager addMigration:migration2];
//    [manager addMigration:migration3];
//    
//    BOOL resultState = NO;
//    NSError *error = nil;
//    /*
//     下面创建版本号表,这个表保存在我们的数据库中,进行数据库版本号的记录,并将我们的数据库升级到最高的版本 表名为固定的“schema_migrations”
//     */
//    if (!manager.hasMigrationsTable) {
//        resultState = [manager createMigrationsTable:&error];
//    }
//    
//    /*
//     升级语句 UINT64_MAX 表示升级到最高版本
//     */
//    resultState = [manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
//    
//    [migration1 migrateDatabase:self.db error:&error];
//    [migration2 migrateDatabase:self.db error:&error];
//    [migration3 migrateDatabase:self.db error:&error];

    
    
//    NSLog(@"Has `schema_migrations` table?: %@", manager.hasMigrationsTable ? @"YES" : @"NO");
//    NSLog(@"Origin Version: %llu", manager.originVersion);
//    NSLog(@"Current version: %llu", manager.currentVersion);
//    NSLog(@"All migrations: %@", manager.migrations);
//    NSLog(@"Applied versions: %@", manager.appliedVersions);
//    NSLog(@"Pending versions: %@", manager.pendingVersions);
    [self.db close];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
