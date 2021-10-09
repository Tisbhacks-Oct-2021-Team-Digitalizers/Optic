import 'package:optic/models/userData.dart';
import 'package:optic/services/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userListProvider =
    FutureProvider.autoDispose<List<UserData>>((ref) async {
  final userDataList = await listUsers();
  ref.maintainState = true;
  return userDataList;
});
