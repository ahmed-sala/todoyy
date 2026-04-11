//
//  TodoManager.m
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import "TodoManager.h"
static NSString *const kTodoListKey = @"TodoListKey";

@implementation TodoManager

+ (instancetype)sharedManager {
    static TodoManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [TodoManager new];
    });
    return sharedInstance;
}





- (void)addTodo:(TodoItem *)todo {
    NSMutableArray *rawTodos = [self loadRawTodos];
    [rawTodos addObject:[todo toDictionary]];
    [self saveRawTodos:rawTodos];
}


- (NSMutableArray<TodoItem *> *)getAllTodos {
    NSMutableArray *rawTodos = [self loadRawTodos];
    NSMutableArray<TodoItem *> *todos = [NSMutableArray new];
    
    for (NSDictionary *dict in rawTodos) {
        TodoItem *item = [TodoItem fromDictionary:dict];
        [todos addObject:item];
    }
    return todos;
}
- (NSMutableArray<TodoItem *> *)getTodosByStatus:(NSInteger)status {
    NSMutableArray<TodoItem *> *allTodos = [self getAllTodos];
    NSMutableArray<TodoItem *> *filteredTodos = [NSMutableArray new];
    
    for (TodoItem *todo in allTodos) {
        if (todo.status == status) {
            [filteredTodos addObject:todo];
        }
    }
    return filteredTodos;
}
- (NSMutableArray<TodoItem *> *)getTodosWithTodoStatus {
    return [self getTodosByStatus:TodoStatusTodo];
}


- (NSMutableArray<TodoItem *> *)getTodosWithInProgressStatus {
    return [self getTodosByStatus:TodoStatusInProgress];
}


- (NSMutableArray<TodoItem *> *)getTodosWithDoneStatus {
    return [self getTodosByStatus:TodoStatusDone];
}


- (TodoItem *)getTodoByUUID:(NSString *)uuid {
    NSMutableArray *rawTodos = [self loadRawTodos];
    
    for (NSDictionary *dict in rawTodos) {
        if ([dict[@"uuid"] isEqualToString:uuid]) {
            return [TodoItem fromDictionary:dict];
        }
    }
    return nil;
}


- (void)updateTodo:(TodoItem *)updatedTodo {
    NSMutableArray *rawTodos = [self loadRawTodos];
    
    for (NSInteger i = 0; i < rawTodos.count; i++) {
        NSDictionary *dict = rawTodos[i];
        if ([dict[@"uuid"] isEqualToString:updatedTodo.uuid]) {
            [rawTodos replaceObjectAtIndex:i withObject:[updatedTodo toDictionary]];
            break;
        }
    }
    [self saveRawTodos:rawTodos];
}


- (void)deleteTodoByUUID:(NSString *)uuid {
    NSMutableArray *rawTodos = [self loadRawTodos];
    
    NSMutableArray *filteredTodos = [NSMutableArray new];
    for (NSDictionary *dict in rawTodos) {
        if (![dict[@"uuid"] isEqualToString:uuid]) {
            [filteredTodos addObject:dict];
        }
    }
    [self saveRawTodos:filteredTodos];
}


- (NSMutableArray<NSDictionary *> *)loadRawTodos {
    NSArray *savedArray = [[NSUserDefaults standardUserDefaults] objectForKey:kTodoListKey];
    if (savedArray) {
        return [savedArray mutableCopy];
    }
    return [NSMutableArray new];
}

- (void)saveRawTodos:(NSArray<NSDictionary *> *)rawTodos {
    [[NSUserDefaults standardUserDefaults] setObject:rawTodos forKey:kTodoListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
