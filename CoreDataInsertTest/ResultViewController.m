//
//  ResultViewController.m
//  CoreDataInsertTest
//
//  Created by akuraru on 2014/01/27.
//  Copyright (c) 2014年 akuraru. All rights reserved.
//

#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <MagicalRecord/NSManagedObject+MagicalRecord.h>
#import "ResultViewController.h"
#import "TestTable.h"
#import "NSManagedObjectContext+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "CoreData+MagicalRecord.h"

@interface ResultViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation ResultViewController {
    NSDate *_startTime;
}

- (void)dealloc {
    self.blocks = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_activityIndicator startAnimating];
    [self performSelectorOnMainThread:@selector(updateStateLabel:) withObject:@"deleting" waitUntilDone:NO];
    [self performSelectorInBackground:@selector(deleteDataBase) withObject:nil];
}

- (void)updateStateLabel:(id)updateStateLabel {
    _stateLabel.text = updateStateLabel;
}

- (void)deleteDataBase {
    [self performSelectorOnMainThread:@selector(deleteObject) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(updateStateLabel:) withObject:@"start Block" waitUntilDone:YES];
    _startTime = [NSDate date];
    [self performSelectorOnMainThread:@selector(startBlock) withObject:nil waitUntilDone:NO];
}

- (void)deleteObject {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSArray *array = [TestTable MR_findAllInContext:context];
    for (int i = 0, _len = array.count;i < _len; i++) {
            [array[i] MR_deleteInContext:context];
    }
    [context MR_saveOnlySelfAndWait];
}

- (void)startBlock {
    if (_blocks) {
        _blocks();
    }
    [self performSelectorOnMainThread:@selector(endBlock) withObject:nil waitUntilDone:NO];
}

- (void)endBlock {
    NSDate *endTime = [NSDate date];
    [_activityIndicator stopAnimating];
    
    _stateLabel.text = @"end block";
    _resultLabel.text = [NSString stringWithFormat:@"%f s", [endTime timeIntervalSinceDate:_startTime]];

    TestTable *t = [TestTable MR_findFirst];
    NSLog(@"%@ : %@ : %@ : %d", _resultLabel.text, t.text, t.date, [[TestTable MR_findAll] count]);
}

@end
