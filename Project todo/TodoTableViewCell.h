//
//  TodoTableViewCell.h
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "TodoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TodoTableViewCell : UITableViewCell

- (void)configureWithTodoItem:(TodoItem *)item;

@end

NS_ASSUME_NONNULL_END
