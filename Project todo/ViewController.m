//
//  ViewController.m
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import "ViewController.h"
#import "TodoItem.h"
#import "TodoTableViewCell.h"
#import "AddToDoViewController.h"
#import "TodoManager.h"
#import "NewTableTableViewCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<TodoItem *> *allItems;
@property (strong, nonatomic) NSArray<TodoItem *> *filteredItems;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, nonatomic) NSDictionary<NSString *, NSArray<TodoItem *> *> *prioritySections;
@property (strong, nonatomic) NSArray<NSString *> *sectionTitles;
@end

@implementation ViewController
- (IBAction)goToAddToDo:(id)sender {
    AddToDoViewController *addToDo =
    [self.storyboard instantiateViewControllerWithIdentifier:@"add"];
    addToDo.modalPresentationStyle = UIModalPresentationPageSheet;

    [self presentViewController:addToDo  animated:YES completion:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;

    UIButtonConfiguration *config = self.addButton.configuration;
    config.imagePadding = 10;
    config.contentInsets = NSDirectionalEdgeInsetsMake(10, 10, 10, 10);
    self.addButton.configuration = config;

    [self styleSearchBar];
    [self styleSegmentControl];


    self.emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.bounds];
    self.emptyLabel.text = @"📝 No Tasks Yet\nTap + to add one";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor systemGrayColor];
    self.emptyLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.emptyLabel.numberOfLines = 0;


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTodos)
                                                 name:@"TodoUpdated"
                                               object:nil];


    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;

    [self.tableView registerClass:[TodoTableViewCell class]
           forCellReuseIdentifier:@"TodoCell"];


    [self.segmentControl addTarget:self
                            action:@selector(segmentChanged:)
                  forControlEvents:UIControlEventValueChanged];

    self.segmentControl.selectedSegmentIndex = 0;


    self.allItems = [[TodoManager sharedManager] getAllTodos];


    [self filterItemsForSegment:0];
}
- (void)reloadTodos {
    self.allItems = [[TodoManager sharedManager] getAllTodos];
    [self filterItemsForSegment:self.segmentControl.selectedSegmentIndex];
    BOOL isEmpty;

    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSInteger total = 0;

        for (NSString *key in self.sectionTitles) {
            total += self.prioritySections[key].count;
        }

        isEmpty = (total == 0);
    } else {
        isEmpty = (self.filteredItems.count == 0);
    }

    self.tableView.backgroundView = isEmpty ? self.emptyLabel : nil;
}

- (void)styleSegmentControl {

    self.segmentControl.backgroundColor = [UIColor systemGray5Color];

    self.segmentControl.selectedSegmentTintColor = [UIColor systemBlueColor];

    NSDictionary *normalAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemGrayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium]
    };

    NSDictionary *selectedAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold]
    };

    [self.segmentControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [self.segmentControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

    self.segmentControl.layer.cornerRadius = 12;
    self.segmentControl.layer.masksToBounds = YES;
}


- (void)segmentChanged:(UISegmentedControl *)sender {
    [self filterItemsForSegment:sender.selectedSegmentIndex];
}

- (void)filterItemsForSegment:(NSInteger)index {

    NSArray *baseArray;

    switch (index) {
        case 0:
            baseArray = [self.allItems copy];
            break;

        case 1:
            baseArray = [self.allItems filteredArrayUsingPredicate:
                         [NSPredicate predicateWithFormat:@"status == %d", TodoStatusTodo]];
            break;

        case 2:
            baseArray = [self.allItems filteredArrayUsingPredicate:
                         [NSPredicate predicateWithFormat:@"status == %d", TodoStatusInProgress]];
            break;

        case 3:
            baseArray = [self.allItems filteredArrayUsingPredicate:
                         [NSPredicate predicateWithFormat:@"status == %d", TodoStatusDone]];
            break;

        case 4: {
            NSMutableArray *high = [NSMutableArray new];
            NSMutableArray *medium = [NSMutableArray new];
            NSMutableArray *low = [NSMutableArray new];

            NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            for (TodoItem *item in self.allItems) {

                BOOL matches = YES;

                if (searchText.length > 0) {
                    matches =
                    [item.title localizedCaseInsensitiveContainsString:searchText] ||
                    [item.todoDescription localizedCaseInsensitiveContainsString:searchText];
                }

                if (!matches) continue;

                if (item.priority == 3) {
                    [high addObject:item];
                } else if (item.priority == 2) {
                    [medium addObject:item];
                } else {
                    [low addObject:item];
                }
            }

            NSMutableArray *titles = [NSMutableArray new];

            if (high.count > 0) [titles addObject:@"High"];
            if (medium.count > 0) [titles addObject:@"Medium"];
            if (low.count > 0) [titles addObject:@"Low"];

            self.sectionTitles = titles;

            self.prioritySections = @{
                @"High": high,
                @"Medium": medium,
                @"Low": low
            };

            [self.tableView reloadData];

            NSInteger total = high.count + medium.count + low.count;
            self.tableView.backgroundView = (total == 0) ? self.emptyLabel : nil;

            return;
        }
        default:
            baseArray = [self.allItems copy];
            break;
    }

    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];


    if (searchText.length > 0) {

        self.filteredItems = [baseArray filteredArrayUsingPredicate:
                              [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", searchText, searchText]];
    } else {
        self.filteredItems = baseArray;
    }

    [self.tableView reloadData];
    BOOL isEmpty;

    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSInteger total = 0;

        for (NSString *key in self.sectionTitles) {
            total += self.prioritySections[key].count;
        }

        isEmpty = (total == 0);
    } else {
        isEmpty = (self.filteredItems.count == 0);
    }

    self.tableView.backgroundView = isEmpty ? self.emptyLabel : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.segmentControl.selectedSegmentIndex == 4) {
        return self.sectionTitles.count;
    }
    return 1;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterItemsForSegment:self.segmentControl.selectedSegmentIndex];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self filterItemsForSegment:self.segmentControl.selectedSegmentIndex];
    [searchBar resignFirstResponder];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSString *title = self.sectionTitles[section];
        return self.prioritySections[title].count;
    }

    return self.filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NewTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewCell"
                                                                  forIndexPath:indexPath];

    TodoItem *item;

    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSString *title = self.sectionTitles[indexPath.section];
        item = self.prioritySections[title][indexPath.row];
    } else {
        item = self.filteredItems[indexPath.row];
    }


    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSString *title = self.sectionTitles[indexPath.section];
        item = self.prioritySections[title][indexPath.row];
    } else {
        item = self.filteredItems[indexPath.row];
    }

    cell.titleLabel.text = item.title;
    cell.descriptionLabel.text = item.todoDescription;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy";
    cell.dateLabel.text = [formatter stringFromDate:item.date];

    if (item.priority == 3) {
        cell.priorityText.text = @"High";
    } else if (item.priority == 2) {
        cell.priorityText.text = @"Medium";
    } else {
        cell.priorityText.text = @"Low";
    }

    if (item.status == 0) {
        cell.statusText.text = @"Todo";
    } else if (item.status == 1) {
        cell.statusText.text = @"In Progress";
    } else {
        cell.statusText.text = @"Done";
    }

    if (item.priority == 3) {
        cell.todoImageView.image = [UIImage imageNamed:@"high"];
    } else if (item.priority == 2) {
        cell.todoImageView.image = [UIImage imageNamed:@"medium"];
    } else {
        cell.todoImageView.image = [UIImage imageNamed:@"low"];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  160;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (self.segmentControl.selectedSegmentIndex == 4) {
        return self.sectionTitles[section];
    }

    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddToDoViewController *addToDo=[self.storyboard instantiateViewControllerWithIdentifier:@"add"];
    TodoItem *item;

    if (self.segmentControl.selectedSegmentIndex == 4) {
        NSString *title = self.sectionTitles[indexPath.section];
        item = self.prioritySections[title][indexPath.row];
    } else {
        item = self.filteredItems[indexPath.row];
    }
    addToDo.item= item;
    addToDo.modalPresentationStyle = UIModalPresentationPageSheet;

    [self presentViewController:addToDo  animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)styleSearchBar {
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"Search tasks...";
    
    UITextField *searchTextField = [self.searchBar valueForKey:@"searchField"];
    
    searchTextField.backgroundColor = [UIColor systemGray6Color];
    
    searchTextField.layer.cornerRadius = 12;
    searchTextField.layer.masksToBounds = YES;
    
    searchTextField.leftView.tintColor = [UIColor systemGrayColor];
    
    searchTextField.textColor = [UIColor labelColor];
    searchTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchBar.layer.shadowOpacity = 0.05;
    self.searchBar.layer.shadowOffset = CGSizeMake(0, 2);
    self.searchBar.layer.shadowRadius = 6;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.searchBar.frame = CGRectMake(16, self.searchBar.frame.origin.y, self.view.frame.size.width - 32, 50);
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

    UIContextualAction *deleteAction =
    [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                            title:@"Delete"
                                          handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

        TodoItem *item = self.filteredItems[indexPath.row];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Task"
                    message:@"Are you sure you want to delete this task?"
                    preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                    style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }];

        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                    style:UIAlertActionStyleDestructive
                    handler:^(UIAlertAction * _Nonnull action) {

            [[TodoManager sharedManager] deleteTodoByUUID:item.uuid];

            [self reloadTodos];
            BOOL isEmpty;

            if (self.segmentControl.selectedSegmentIndex == 4) {
                NSInteger total = 0;

                for (NSString *key in self.sectionTitles) {
                    total += self.prioritySections[key].count;
                }

                isEmpty = (total == 0);
            } else {
                isEmpty = (self.filteredItems.count == 0);
            }

            self.tableView.backgroundView = isEmpty ? self.emptyLabel : nil;
            completionHandler(YES);
        }];

        [alert addAction:cancel];
        [alert addAction:delete];

        [self presentViewController:alert animated:YES completion:nil];
        BOOL isEmpty;

        if (self.segmentControl.selectedSegmentIndex == 4) {
            NSInteger total = 0;

            for (NSString *key in self.sectionTitles) {
                total += self.prioritySections[key].count;
            }

            isEmpty = (total == 0);
        } else {
            isEmpty = (self.filteredItems.count == 0);
        }

        self.tableView.backgroundView = isEmpty ? self.emptyLabel : nil;
        completionHandler(YES);
    }];

    deleteAction.image = [UIImage systemImageNamed:@"trash"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    config.performsFirstActionWithFullSwipe = YES;

    return config;
}
@end
