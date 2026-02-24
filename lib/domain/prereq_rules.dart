import "../data/db/app_db.dart";
import "mastery_rules.dart";
import "movement_tier.dart";

String normalizePrereqType(String prereqTypeRaw) {
  final t = prereqTypeRaw.trim().toLowerCase();
  if (t.isEmpty) return "progress";
  if (t == "master") return "mastered";

  switch (t) {
    case "unlocked":
    case "progress":
    case "bronze":
    case "silver":
    case "gold":
    case "mastered":
      return t;
    default:
      return "progress";
  }
}

bool isPrereqSatisfied({
  required String prereqType,
  required String currentState,
}) {
  final required = normalizePrereqType(prereqType);
  if (required == "unlocked") {
    return currentState != "locked";
  }
  return isAtLeastTier(currentState: currentState, requiredState: required);
}

String prereqLabel(String prereqType) {
  switch (normalizePrereqType(prereqType)) {
    case "unlocked":
      return "Unlocked";
    case "progress":
      return "Progress";
    case "bronze":
      return "Bronze";
    case "silver":
      return "Silver";
    case "gold":
      return "Gold";
    case "mastered":
      return "Mastered";
    default:
      return prereqType;
  }
}

MasteryTarget? targetForPrereqTier(Movement movement, String prereqType) {
  final tiers = MasteryRules.tiersForMovementEntity(movement);
  switch (normalizePrereqType(prereqType)) {
    case "progress":
      return tiers.progress;
    case "bronze":
      return tiers.bronze;
    case "silver":
      return tiers.silver;
    case "gold":
      return tiers.gold;
    case "mastered":
      return tiers.mastered;
    default:
      return null;
  }
}
