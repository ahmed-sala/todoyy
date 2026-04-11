//
//  TodoItem.m
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import "TodoItem.h"

@implementation TodoItem


- (instancetype)initWithTitle:(NSString *)title
              todoDescription:(NSString *)todoDescription
                     priority:(NSInteger)priority
                 reminderDate:(NSDate *) reminderDate
                   isReminder:(BOOL)isReminder
                       status:(NSInteger)status
{
    self = [super init];
    if (self) {
        _uuid = [[NSUUID UUID] UUIDString];
        _title = title;
        _todoDescription = todoDescription;
        _date = [NSDate date]; 
        _priority = priority;
        _status = status;
        _reminderDate=reminderDate;
        _isReminder=isReminder;
    }
    return self;
}


- (NSDictionary *)toDictionary {
    return @{
        @"uuid": self.uuid ?: @"",
        @"title": self.title ?: @"",
        @"todoDescription": self.todoDescription ?: @"",
        @"date": @([self.date timeIntervalSince1970]),
        @"priority": @(self.priority),
        @"status": @(self.status),
        @"isReminder": @(self.isReminder),
        @"reminderDate":@([self.date timeIntervalSince1970])
    };
}

+ (TodoItem *)fromDictionary:(NSDictionary *)dict {

    TodoItem *item = [[TodoItem alloc] init];

    item.uuid = dict[@"uuid"];
    item.title = dict[@"title"];
    item.isReminder = dict[@"isReminder"];
    item.todoDescription = dict[@"todoDescription"];
    item.date = [NSDate dateWithTimeIntervalSince1970:[dict[@"date"] doubleValue]];
    item.priority = [dict[@"priority"] integerValue];
    item.status = [dict[@"status"] integerValue];
    item.reminderDate= [NSDate dateWithTimeIntervalSince1970:[dict[@"reminderDate"] doubleValue]];

    return item;
}
- (NSString *)statusString {
    switch (self.status) {
        case TodoStatusTodo:return @"Todo";
        case TodoStatusInProgress:return @"In Progress";
        case TodoStatusDone:return @"Done";
        default:return @"Unknown";
    }
}
@end
