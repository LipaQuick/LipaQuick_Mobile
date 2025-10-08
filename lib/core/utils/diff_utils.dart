import 'package:lipa_quick/core/models/contacts/contacts.dart';

class DiffUtils{
  ListMatch<dynamic> getSeperatedContacts(List<ContactsAPI> data){
    return data.splitMatch((element) => element.id == null);
  }
}

extension SplitMatch<T> on List<T> {
  ListMatch<T> splitMatch(bool Function(T element) matchFunction) {
    final listMatch = ListMatch<T>();

    for (final element in this) {
      if (matchFunction(element)) {
        listMatch.matched.add(element);
      } else {
        listMatch.unmatched.add(element);
      }
    }

    return listMatch;
  }
}

class ListMatch<T> {
  List<T> matched = <T>[];
  List<T> unmatched = <T>[];
}

class DiffUtil {
  /// This function calculates the difference between two lists.
  /// It returns a list of `DiffResult` which describes the changes needed
  /// to convert the old list into the new list.
  static List<DiffResult<T>> calculateDiff<T>(List<T> oldList, List<T> newList) {
    final List<DiffResult<T>> diffResults = [];

    int oldListIndex = 0;
    int newListIndex = 0;

    while (oldListIndex < oldList.length && newListIndex < newList.length) {
      final oldItem = oldList[oldListIndex];
      final newItem = newList[newListIndex];

      if (oldItem == newItem) {
        oldListIndex++;
        newListIndex++;
      } else if (!newList.contains(oldItem)) {
        diffResults.add(DiffResult<T>(DiffAction.delete, oldItem, oldListIndex));
        oldListIndex++;
      } else if (!oldList.contains(newItem)) {
        diffResults.add(DiffResult<T>(DiffAction.insert, newItem, newListIndex));
        newListIndex++;
      } else {
        diffResults.add(DiffResult<T>(DiffAction.change, newItem, newListIndex));
        oldListIndex++;
        newListIndex++;
      }
    }

    while (oldListIndex < oldList.length) {
      diffResults.add(DiffResult<T>(DiffAction.delete, oldList[oldListIndex], oldListIndex));
      oldListIndex++;
    }

    while (newListIndex < newList.length) {
      diffResults.add(DiffResult<T>(DiffAction.insert, newList[newListIndex], newListIndex));
      newListIndex++;
    }

    return diffResults;
  }

  /// This function applies the list of `DiffResult` changes to the old list
  /// and returns the updated list.
  static List<T> applyDiff<T>(List<T> oldList, List<DiffResult<T>> diffResults) {
    final List<T> updatedList = List.from(oldList);

    for (final result in diffResults) {
      switch (result.action) {
        case DiffAction.insert:
          updatedList.insert(result.index, result.item);
          break;
        case DiffAction.delete:
          updatedList.removeAt(result.index);
          break;
        case DiffAction.change:
          updatedList[result.index] = result.item;
          break;
      }
    }

    return updatedList;
  }
}

enum DiffAction { insert, delete, change }

class DiffResult<T> {
  final DiffAction action;
  final T item;
  final int index;

  DiffResult(this.action, this.item, this.index);

  @override
  String toString() {
    return 'DiffResult{action: $action, item: $item, index: $index}';
  }
}
