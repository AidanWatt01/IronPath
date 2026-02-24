import "package:flutter_test/flutter_test.dart";

import "package:cali_skill_tree/domain/movement_tier.dart";

void main() {
  group("movement tier ranking", () {
    test("supports master + mastered aliases", () {
      expect(tierRankFromState("master"), 6);
      expect(tierRankFromState("mastered"), 6);
    });

    test("orders tiers correctly for prerequisites", () {
      expect(
        isAtLeastTier(currentState: "gold", requiredState: "silver"),
        isTrue,
      );
      expect(
        isAtLeastTier(currentState: "progress", requiredState: "bronze"),
        isFalse,
      );
      expect(
        isAtLeastTier(currentState: "locked", requiredState: "unlocked"),
        isFalse,
      );
    });

    test("maps enum tier to persistence state", () {
      expect(stateFromTier(MovementTier.locked), "locked");
      expect(stateFromTier(MovementTier.unlocked), "unlocked");
      expect(stateFromTier(MovementTier.progress), "progress");
      expect(stateFromTier(MovementTier.bronze), "bronze");
      expect(stateFromTier(MovementTier.silver), "silver");
      expect(stateFromTier(MovementTier.gold), "gold");
      expect(stateFromTier(MovementTier.mastered), "mastered");
    });
  });
}
