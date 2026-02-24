import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";

QueryExecutor openAppDbConnectionImpl() {
  return driftDatabase(
    name: "cali_skill_tree",
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse("sqlite3.wasm"),
      driftWorker: Uri.parse("drift_worker.js"),
    ),
  );
}
