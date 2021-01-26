import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test "Map.from" and "List.from" ', () {
    // Map.from
    // ignore: omit_local_variable_types
    final Map _newMap = {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.1': 'hgello'},
        {'key3.2': 'hgello'}
      ]
    };
    // ignore: omit_local_variable_types
    final Map _copyMap = Map.from(_newMap);

    /**
     * With: _copyMap['key3'].removeAt(0)
     * Result _newMap & _copyMap:
    {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.1': 'hgello'}
      ]
    }
     */
    _copyMap['key3'].removeAt(0);
    expect(_newMap, _copyMap);

    //----------------------------------------------
    // List.from
    // ignore: omit_local_variable_types
    final List _newList = [
      {'key1': 'hello', 'key2': 'hello2', 'key3': 'hello3'},
      {'key1.2': 'hello', 'key2.2': 'hello2', 'key3.2': 'hello3'},
      {'key1.3': 'hello', 'key2.3': 'hello2', 'key3.3': 'hello3'}
    ];
    // ignore: omit_local_variable_types
    final List _copyList = List.from(_newList);

    // ignore: omit_local_variable_types
    final List _listResult = [
      {'key1': 'hello', 'key2': 'hello2', 'key3': 'hello3'},
      {'key1.3': 'hello', 'key2.3': 'hello2', 'key3.3': 'hello3'}
    ];

    /**
     * With: _copyList.removeAt(1)
     * Result _newList:
    [
      {'key1': 'hello', 'key2': 'hello2', 'key3': 'hello3'},
      {'key1.2': 'hello', 'key2.2': 'hello2', 'key3.2': 'hello3'},
      {'key1.3': 'hello', 'key2.3': 'hello2', 'key3.3': 'hello3'}
    ]
     * Result _copyList:
    [
      {'key1': 'hello', 'key2': 'hello2', 'key3': 'hello3'},
      {'key1.3': 'hello', 'key2.3': 'hello2', 'key3.3': 'hello3'}
    ]
     */
    _copyList.removeAt(1);
    expect(_copyList, _listResult);
    //----------------------------------------------
    // ignore: omit_local_variable_types
    final Map _newMap_2 = {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.1': 'hgello'},
        {'key3.2': 'hgello'}
      ]
    };
    // ignore: omit_local_variable_types
    final Map _copyMap_2 = {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': List.from(_newMap_2['key3'])
    };

    // ignore: omit_local_variable_types
    final Map _mapResult = {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.2': 'hgello'}
      ]
    };
    /** 
     * With  : _copyMap_2['key3'].removeAt(0)
     * Result: _newMap_2
    {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.1': 'hgello'},
        c
      ]
    }
    * Result _copyMap_2
    {
      'key1': 'hello',
      'key2': 'hello 2',
      'key3': [
        {'key3.2': 'hgello'}
      ]
    }
     */
    _copyMap_2['key3'].removeAt(0);
    expect(_copyMap_2, _mapResult);
  });
}
