// lib/domain/movement_tier.dart

enum MovementTier
{
  locked,
  unlocked,
  progress,
  bronze,
  silver,
  gold,
  mastered,
}

int tierRankFromState(String state)
{
  switch (state)
  {
    case "locked": return 0;
    case "unlocked": return 1;

    case "progress": return 2;
    case "bronze": return 3;
    case "silver": return 4;
    case "gold": return 5;

    // keep backward compatibility with older naming
    case "master": return 6;
    case "mastered": return 6;
    default: return 0;
  }
}

String stateFromTier(MovementTier tier)
{
  switch (tier)
  {
    case MovementTier.locked: return "locked";
    case MovementTier.unlocked: return "unlocked";
    case MovementTier.progress: return "progress";
    case MovementTier.bronze: return "bronze";
    case MovementTier.silver: return "silver";
    case MovementTier.gold: return "gold";
    case MovementTier.mastered: return "mastered";
  }
}

bool isAtLeastTier({
  required String currentState,
  required String requiredState,
})
{
  return tierRankFromState(currentState) >= tierRankFromState(requiredState);
}