//
//  TodoManager.h
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import <Foundation/Foundation.h>
#import "TodoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TodoManager : NSObject
+ (instancetype)sharedManager;

- (void)addTodo:(TodoItem *)todo;
- (NSMutableArray<TodoItem *> *)getAllTodos;
- (NSMutableArray<TodoItem *> *)getTodosByStatus:(NSInteger)status;
- (NSMutableArray<TodoItem *> *)getTodosWithTodoStatus;
- (NSMutableArray<TodoItem *> *)getTodosWithInProgressStatus;
- (NSMutableArray<TodoItem *> *)getTodosWithDoneStatus;

- (TodoItem *)getTodoByUUID:(NSString *)uuid;
- (void)updateTodo:(TodoItem *)updatedTodo;
- (void)deleteTodoByUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
