//
//  TodoItem.h
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TodoStatus) {
    TodoStatusTodo       = 0,
    TodoStatusInProgress = 1,
    TodoStatusDone       = 2
};

@interface TodoItem : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *todoDescription;
@property (nonatomic, strong) NSDate   *date;\
@property (nonatomic, strong) NSDate   *reminderDate;

@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL isReminder;

- (instancetype)initWithTitle:(NSString *)title
              todoDescription:(NSString *)todoDescription
                     priority:(NSInteger)priority
                        reminderDate:(NSDate *) reminderDate
                        isReminder:(BOOL)isReminder
                       status:(NSInteger)status;
                    

- (NSDictionary *)toDictionary;
+ (TodoItem *)fromDictionary:(NSDictionary *)dict;
- (NSString *)statusString;


@end
NS_ASSUME_NONNULL_END
