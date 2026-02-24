import "dart:io";

import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:path_provider/path_provider.dart";

QueryExecutor openAppDbConnectionImpl() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/cali_skill_tree.sqlite");
    return NativeDatabase.createInBackground(file);
  });
}
