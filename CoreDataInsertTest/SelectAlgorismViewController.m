//
//  SelectAlgorismViewController.m
//  CoreDataInsertTest
//
//  Created by akuraru on 2014/01/27.
//  Copyright (c) 2014年 akuraru. All rights reserved.
//

#import "SelectAlgorismViewController.h"
#import "ResultViewController.h"
#import "CoreData+MagicalRecord.h"
#import "TestTable.h"

@interface SelectAlgorismViewController ()

@end

@implementation SelectAlgorismViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [MagicalRecord setupCoreDataStack];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Insert"]) {
        [segue.destinationViewController setBlocks:sender];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"Insert" sender:[self blocks:indexPath]];
}


- (id)blocks:(NSIndexPath *)indexPath {
    return @[
            [self simpleInsert],
            [self saveTo100Insert],
            [self saveTo10000Insert],
            [self saveTo100thread],
            [self saveTo100threadAndSleep],
    ][indexPath.row];
}

- (id)simpleInsert {
    return ^{
        for (int i = 0; i < 10000; i++) {
            NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
            TestTable *t = [TestTable MR_createInContext:context];
            t.text = @"hoge";
            t.date = [NSDate date];
            [context MR_saveOnlySelfAndWait];
        }
    };
}


- (id)saveTo100Insert {
    return ^{
        for (int i = 0; i < 100; i++) {
            NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
            for (int j = 0; j < 100; j++) {
                TestTable *t = [TestTable MR_createInContext:context];
                t.text = @"hoge";
                t.date = [NSDate date];
            }
            [context MR_saveOnlySelfAndWait];
        }
    };
}

- (id)saveTo10000Insert {
    return ^{
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        for (int j = 0; j < 10000; j++) {
            TestTable *t = [TestTable MR_createInContext:context];
            t.text = @"hoge";
            t.date = [NSDate date];
        }
        [context MR_saveOnlySelfAndWait];
    };
}

- (id)saveTo100thread {
    return ^{
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            [queue addOperationWithBlock:^{
                NSManagedObjectContext *context = [NSManagedObjectContext MR_context];
                for (int j = 0; j < 100; j++) {
                    TestTable *t = [TestTable MR_createInContext:context];
                    t.text = @"hoge";
                    t.date = [NSDate date];
                }
                [array addObject:context];
            }];
        }
        [queue waitUntilAllOperationsAreFinished];
        for (NSManagedObjectContext *c in array) {
            [c MR_saveToPersistentStoreAndWait];
        }

    };
}

- (id)saveTo100threadAndSleep {
    return ^{
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            [queue addOperationWithBlock:^{
                NSManagedObjectContext *context = [NSManagedObjectContext MR_context];
                for (int j = 0; j < 100; j++) {
                    TestTable *t = [TestTable MR_createInContext:context];
                    t.text = @"hoge";
                    t.date = [NSDate date];
                    [NSThread sleepForTimeInterval:0.01];
                }
                [array addObject:context];
            }];
        }
        [queue waitUntilAllOperationsAreFinished];
        for (NSManagedObjectContext *c in array) {
            [c MR_saveToPersistentStoreAndWait];
        }
    };
}
@end
