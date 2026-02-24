import "package:drift/drift.dart";

import "app_db_connection_native.dart"
    if (dart.library.html) "app_db_connection_web.dart";

QueryExecutor openAppDbConnection() {
  return openAppDbConnectionImpl();
}
