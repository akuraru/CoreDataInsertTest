//
//  TestTable.h
//  CoreDataInsertTest
//
//  Created by akuraru on 2014/01/27.
//  Copyright (c) 2014年 akuraru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestTable : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;

@end
