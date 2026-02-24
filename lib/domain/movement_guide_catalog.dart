// lib/domain/movement_guide_catalog.dart

class SeedMovementGuide {
  const SeedMovementGuide({
    required this.movementId,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.setup,
    required this.execution,
    required this.cues,
    required this.commonMistakes,
    this.regressions = const [],
    this.progressions = const [],
    this.youtubeQuery = "",
  });

  final String movementId;

  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;

  final String setup;
  final String execution;
  final List<String> cues;
  final List<String> commonMistakes;

  final List<String> regressions;
  final List<String> progressions;

  final String youtubeQuery;
}

const seedMovementGuides = <SeedMovementGuide>[
  // =========================
  // MOBILITY / PREHAB
  // =========================
  SeedMovementGuide(
    movementId: "wrist_mobility",
    primaryMuscles: ["Wrist flexors/extensors"],
    secondaryMuscles: ["Forearms", "Shoulders"],
    setup:
        "Hands on floor/table. Fingers forward. Elbows straight but not locked hard.",
    execution:
        "Move through pain-free ranges: circles, gentle forward leans, and side-to-side shifts. Keep pressure even across the palm.",
    cues: ["Slow + controlled", "Keep palm flat", "Stay pain-free", "Breathe"],
    commonMistakes: [
      "Forcing end range",
      "Letting palm lift",
      "Moving too fast",
      "Sharp pain",
    ],
    regressions: ["Do on a table/wall", "Smaller leans"],
    progressions: ["Planche lean", "Frog stand"],
    youtubeQuery: "wrist mobility for calisthenics handstands planche",
  ),
  SeedMovementGuide(
    movementId: "shoulder_dislocates",
    primaryMuscles: ["Shoulders (mobility)", "Chest (stretch)"],
    secondaryMuscles: ["Lats (stretch)", "Upper back", "Rotator cuff"],
    setup: "Use a band/broom. Wide grip. Stand tall, ribs down.",
    execution:
        "Raise arms overhead and pass behind the body, then return. Keep elbows straight and move slowly.",
    cues: ["Wide grip first", "Ribs down", "No shrugging", "Smooth tempo"],
    commonMistakes: [
      "Too narrow grip",
      "Bending elbows",
      "Rib flare",
      "Painful range",
    ],
    regressions: ["Wider grip", "Partial range"],
    progressions: ["Narrower grip over time", "Bridge prep"],
    youtubeQuery: "shoulder dislocates band proper form mobility",
  ),
  SeedMovementGuide(
    movementId: "thoracic_extension",
    primaryMuscles: ["Thoracic spine (mobility)"],
    secondaryMuscles: ["Upper back extensors", "Lats (stretch)"],
    setup:
        "Sit or kneel. Hands behind head or on a wall/foam roller. Keep hips stable.",
    execution:
        "Extend through the upper back (not lower back). Pause at end range, then return to neutral.",
    cues: [
      "Move from mid/upper back",
      "Ribs stay down",
      "Neck long",
      "Slow reps",
    ],
    commonMistakes: ["Overextending low back", "Rib flare", "Rushing"],
    regressions: ["Smaller range", "Supported on wall"],
    progressions: ["Bridge prep", "Wall handstand"],
    youtubeQuery: "thoracic extension drills overhead mobility",
  ),
  SeedMovementGuide(
    movementId: "hamstring_mobility",
    primaryMuscles: ["Hamstrings (stretch)"],
    secondaryMuscles: [
      "Calves (stretch)",
      "Glutes (stretch)",
      "Hip flexors (control)",
    ],
    setup:
        "Seated pike or standing hinge. Keep spine long, knees softly unlocked if needed.",
    execution:
        "Hinge from hips. Hold a gentle stretch. If doing pulses, make them small and controlled.",
    cues: [
      "Hinge first",
      "Long spine",
      "Relax the neck",
      "Breathe into the stretch",
    ],
    commonMistakes: [
      "Rounding hard",
      "Forcing toes",
      "Nerve pain/sharp tingles",
    ],
    regressions: ["Bend knees slightly", "Use a strap"],
    progressions: ["Pike compression", "Seated pike lift"],
    youtubeQuery: "hamstring mobility pike stretch safe form",
  ),
  SeedMovementGuide(
    movementId: "ankle_mobility",
    primaryMuscles: ["Ankles (dorsiflexion mobility)"],
    secondaryMuscles: ["Calves (stretch)", "Tibialis anterior"],
    setup: "Use a wall or rack for support. Keep heel planted the whole time.",
    execution:
        "Drive knee over toes in a pain-free range and hold briefly. Repeat controlled reps each side.",
    cues: ["Heel stays down", "Knee tracks toes", "Slow reps", "No sharp pain"],
    commonMistakes: ["Heel lifting", "Knee collapsing inward", "Forcing range"],
    regressions: ["Smaller range", "Assisted support"],
    progressions: ["Cossack squat mobility", "Cossack squat"],
    youtubeQuery: "ankle dorsiflexion mobility wall drill proper form",
  ),
  SeedMovementGuide(
    movementId: "hip_flexor_mobility",
    primaryMuscles: ["Hip flexors (stretch)"],
    secondaryMuscles: ["Quads (stretch)", "Glutes (stability)"],
    setup:
        "Half-kneeling lunge stance. Tuck pelvis slightly and brace ribs down.",
    execution:
        "Shift forward gently while keeping glute of the kneeling side squeezed. Hold and breathe.",
    cues: [
      "Posterior pelvic tilt",
      "Glute squeezed",
      "Ribs down",
      "Breathe slowly",
    ],
    commonMistakes: [
      "Arching low back",
      "Leaning forward too far",
      "Losing pelvic tuck",
    ],
    regressions: ["Shorter hold", "Hands supported"],
    progressions: ["Couch stretch", "Bridge prep"],
    youtubeQuery: "half kneeling hip flexor stretch proper form",
  ),
  SeedMovementGuide(
    movementId: "pancake_stretch",
    primaryMuscles: ["Adductors (stretch)", "Hamstrings (stretch)"],
    secondaryMuscles: ["Glutes (control)", "Hip flexors (control)"],
    setup:
        "Wide straddle sit. Knees/feet point up. Hands in front for support.",
    execution:
        "Hinge forward with a long spine. Hold and breathe. Optionally add small controlled pulses.",
    cues: ["Hinge, don’t fold", "Knees up", "Chest forward", "Stay relaxed"],
    commonMistakes: [
      "Rounding and collapsing",
      "Feet turning out",
      "Forcing depth",
    ],
    regressions: ["Narrower straddle", "Sit on a cushion"],
    progressions: ["V-sit", "Straddle press handstand"],
    youtubeQuery: "pancake stretch proper form straddle flexibility",
  ),
  SeedMovementGuide(
    movementId: "couch_stretch",
    primaryMuscles: ["Quads (stretch)", "Hip flexors (stretch)"],
    secondaryMuscles: ["Glutes (stability)", "Core"],
    setup:
        "Kneel with back shin against wall/couch. Front foot planted. Brace and lightly tuck pelvis.",
    execution:
        "Move torso upright as tolerated while keeping glute squeezed on the kneeling side.",
    cues: ["Glute on", "Ribs down", "Stay tall", "Breathe"],
    commonMistakes: [
      "Overarching low back",
      "Forcing depth",
      "Losing front-foot stability",
    ],
    regressions: ["Move knee farther from wall", "Use shorter holds"],
    progressions: ["Bridge prep", "Deep lunge work"],
    youtubeQuery: "couch stretch proper form hip flexor quad",
  ),
  SeedMovementGuide(
    movementId: "bridge_prep",
    primaryMuscles: ["Shoulders (mobility)", "Thoracic spine (mobility)"],
    secondaryMuscles: ["Hip flexors (stretch)", "Spinal extensors"],
    setup:
        "Wall shoulder opens or elevated surface. Warm wrists/shoulders first.",
    execution:
        "Open shoulders gradually. Keep ribs controlled. Stop before sharp pinching.",
    cues: ["Breathe", "Ribs down", "Shoulders open slowly", "No pain"],
    commonMistakes: [
      "Dumping into low back",
      "Elbows bending",
      "Pushing through pain",
    ],
    regressions: ["Higher surface", "Smaller range"],
    progressions: ["Bridge"],
    youtubeQuery: "bridge prep shoulder opening thoracic extension drills",
  ),
  SeedMovementGuide(
    movementId: "cossack_squat_mobility",
    primaryMuscles: ["Adductors", "Glutes"],
    secondaryMuscles: ["Ankles (mobility)", "Hamstrings", "Quads"],
    setup:
        "Wide stance with toes slightly out. Keep chest tall and use support as needed.",
    execution:
        "Shift into one side squat while opposite leg stays long. Alternate sides with control.",
    cues: [
      "Sit into hip",
      "Heel down on working side",
      "Tall chest",
      "Slow transitions",
    ],
    commonMistakes: ["Collapsing chest", "Heel lifting", "Bouncing into depth"],
    regressions: ["Shallower range", "Support with hands"],
    progressions: ["Cossack squat", "Pistol prep"],
    youtubeQuery: "cossack squat mobility drill proper form",
  ),
  SeedMovementGuide(
    movementId: "bridge",
    primaryMuscles: ["Spinal extensors", "Glutes"],
    secondaryMuscles: ["Shoulders", "Quads", "Upper back"],
    setup:
        "Lie on back. Feet flat near glutes. Hands by ears (fingers toward shoulders).",
    execution:
        "Press up to bridge. Try to straighten arms, push chest through shoulders, and keep steady breathing.",
    cues: ["Push through hands + feet", "Chest open", "Breathe", "Arms long"],
    commonMistakes: [
      "Elbows flaring/bending",
      "Knees splaying out",
      "All stress in low back",
      "Holding breath",
    ],
    regressions: ["Bridge prep", "Elevated bridge (hands on box)"],
    progressions: ["Longer holds", "Wall walk (later)"],
    youtubeQuery: "full bridge hold proper form shoulders thoracic",
  ),

  // =========================
  // CORE / FOUNDATION
  // =========================
  SeedMovementGuide(
    movementId: "plank",
    primaryMuscles: ["Core (abs)"],
    secondaryMuscles: ["Glutes", "Shoulders"],
    setup:
        "Elbows under shoulders. Feet together or hip-width. Squeeze glutes.",
    execution:
        "Hold a straight line head-to-heels. Breathe without losing brace.",
    cues: [
      "Ribs down",
      "Posterior pelvic tilt",
      "Push floor away",
      "Neck neutral",
    ],
    commonMistakes: [
      "Hips sagging",
      "Hips too high",
      "Holding breath",
      "Shoulders collapsing",
    ],
    regressions: ["Knee plank", "Shorter holds"],
    progressions: ["Hollow hold", "Plank shoulder taps (later)"],
    youtubeQuery: "plank proper form posterior pelvic tilt",
  ),
  SeedMovementGuide(
    movementId: "side_plank",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Glute medius", "Shoulders"],
    setup: "Elbow under shoulder. Feet stacked (or staggered for easier).",
    execution: "Lift hips into a straight line. Hold steady and breathe.",
    cues: ["Hips high", "Shoulder packed", "Ribs down", "Glutes tight"],
    commonMistakes: [
      "Hips dropping",
      "Shoulder shrugging",
      "Rotating forward/back",
    ],
    regressions: ["Knee side plank", "Staggered feet"],
    progressions: ["Longer holds", "Star plank (later)"],
    youtubeQuery: "side plank proper form obliques glute med",
  ),
  SeedMovementGuide(
    movementId: "hollow_hold",
    primaryMuscles: ["Abs (deep core)"],
    secondaryMuscles: ["Hip flexors", "Quads"],
    setup: "Lie on back. Flatten low back to floor (posterior pelvic tilt).",
    execution: "Lift shoulders and legs. Hold shape without low back lifting.",
    cues: ["Low back stays down", "Ribs down", "Reach long", "Breathe"],
    commonMistakes: [
      "Arching low back",
      "Tucking chin hard",
      "Legs too low too soon",
    ],
    regressions: ["Tuck hollow", "One leg bent"],
    progressions: ["Harder lever", "Tuck front lever (carryover)"],
    youtubeQuery: "hollow body hold proper form posterior pelvic tilt",
  ),
  SeedMovementGuide(
    movementId: "arch_hold",
    primaryMuscles: ["Spinal extensors", "Glutes"],
    secondaryMuscles: ["Upper back", "Hamstrings"],
    setup: "Lie face down. Arms overhead or by sides. Squeeze glutes.",
    execution:
        "Lift chest + legs slightly. Keep neck neutral. Hold with control.",
    cues: ["Glutes on", "Reach long", "Neck neutral", "Small lift is fine"],
    commonMistakes: [
      "Cranking neck",
      "Overarching low back",
      "Fast flailing reps",
    ],
    regressions: ["Arms by sides", "Only chest or only legs"],
    progressions: ["Harder lever", "Dragon flag (later)"],
    youtubeQuery: "superman arch hold proper form posterior chain",
  ),
  SeedMovementGuide(
    movementId: "hanging_knee_raise",
    primaryMuscles: ["Abs"],
    secondaryMuscles: ["Hip flexors", "Forearms", "Lats (stability)"],
    setup:
        "Hang from bar. Start in active hang (shoulders down). Legs together.",
    execution:
        "Curl knees toward chest with minimal swing. Lower slowly to full hang.",
    cues: [
      "No swing",
      "Posterior pelvic tilt at top",
      "Control down",
      "Shoulders packed",
    ],
    commonMistakes: ["Kipping", "Half range", "Shrugging", "Dropping fast"],
    regressions: ["Captain chair knee raises", "Smaller raise"],
    progressions: ["Hanging leg raise", "Hanging oblique raise"],
    youtubeQuery: "hanging knee raise strict form no swing",
  ),
  SeedMovementGuide(
    movementId: "hanging_leg_raise",
    primaryMuscles: ["Abs"],
    secondaryMuscles: ["Hip flexors", "Forearms", "Lats (stability)"],
    setup:
        "Active hang. Legs straight and together. Start controlled and still.",
    execution:
        "Raise straight legs to at least hip height. Pause briefly. Lower slowly.",
    cues: ["Stay hollow", "No swing", "Legs together", "Control the descent"],
    commonMistakes: [
      "Swinging/kipping",
      "Bending knees",
      "Using momentum",
      "Shrugging",
    ],
    regressions: ["Hanging knee raise"],
    progressions: ["Toes-to-bar", "Windshield wipers"],
    youtubeQuery: "strict hanging leg raise proper form",
  ),
  SeedMovementGuide(
    movementId: "toes_to_bar",
    primaryMuscles: ["Abs"],
    secondaryMuscles: ["Hip flexors", "Forearms", "Lats (stability)"],
    setup: "Active hang. Start dead still. Grip strong.",
    execution:
        "Lift legs to touch bar with toes. Control down to full hang (strict).",
    cues: ["No swing", "Ribs down", "Touch with control", "Full hang reset"],
    commonMistakes: [
      "Kipping",
      "Incomplete touch",
      "No control down",
      "Shrugging",
    ],
    regressions: ["Hanging leg raise"],
    progressions: ["Strict reps for volume", "Windshield wipers"],
    youtubeQuery: "strict toes to bar no kip",
  ),
  SeedMovementGuide(
    movementId: "tuck_l_sit",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Triceps", "Shoulders (depression)", "Quads"],
    setup:
        "Hands on parallettes/floor. Lock elbows. Push tall through shoulders.",
    execution: "Lift knees to chest and hold. Keep torso upright and stable.",
    cues: ["Elbows locked", "Shoulders down", "Knees high", "Breathe"],
    commonMistakes: [
      "Bent elbows",
      "Shrugging",
      "Knees drifting down",
      "Leaning back a lot",
    ],
    regressions: ["Toe support tuck", "Short holds"],
    progressions: ["L-sit", "Seated pike lift"],
    youtubeQuery: "tuck l sit hold proper form shoulder depression",
  ),
  SeedMovementGuide(
    movementId: "l_sit",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Triceps", "Shoulders (depression)", "Quads"],
    setup: "Hands on parallettes/bars. Elbows locked. Shoulder blades down.",
    execution:
        "Lift straight legs to parallel and hold. Keep hips slightly tucked.",
    cues: ["Lock elbows", "Push tall", "Legs straight", "Toes pointed"],
    commonMistakes: [
      "Bent knees",
      "Shoulders shrugged",
      "Leaning way back",
      "Low legs",
    ],
    regressions: ["Tuck L-sit"],
    progressions: ["V-sit", "Ring L-sit support"],
    youtubeQuery: "l sit hold strict form compression",
  ),
  SeedMovementGuide(
    movementId: "v_sit",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Quads", "Shoulders", "Triceps"],
    setup:
        "Strong L-sit base. Warm hips/hamstrings. Hands stable on bars/parallettes.",
    execution:
        "From L-sit, compress and lift legs higher while keeping elbows locked.",
    cues: ["Compress hard", "Stay tall", "Legs straight", "Breathe"],
    commonMistakes: [
      "Bending knees",
      "Collapsing shoulders",
      "Leaning back to cheat",
    ],
    regressions: ["L-sit", "Straddle compression"],
    progressions: ["Press handstand drills"],
    youtubeQuery: "v sit hold calisthenics compression proper form",
  ),
  SeedMovementGuide(
    movementId: "hanging_oblique_raise",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Abs", "Hip flexors", "Forearms"],
    setup:
        "Active hang. Start still. Knees bent (or straight legs for harder).",
    execution:
        "Raise knees/legs toward one side, return center, repeat other side with control.",
    cues: ["No swing", "Rotate from trunk", "Control down", "Shoulders down"],
    commonMistakes: [
      "Momentum swing",
      "Shrugging",
      "Tiny range",
      "Twisting neck",
    ],
    regressions: ["Knee-only oblique raise", "Smaller range"],
    progressions: ["Windshield wipers"],
    youtubeQuery: "hanging oblique knee raise strict form",
  ),
  SeedMovementGuide(
    movementId: "hanging_windshield_wiper",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Abs", "Hip flexors", "Forearms", "Lats (stability)"],
    setup: "Active hang. Prefer legs raised high (at least to hip height).",
    execution:
        "Move legs side-to-side in a controlled arc. Keep shoulders packed and minimize swing.",
    cues: ["Slow arcs", "No swing", "Ribs down", "Control both directions"],
    commonMistakes: [
      "Kipping",
      "Dropping legs too low",
      "Shrugging",
      "Rushing reps",
    ],
    regressions: ["Hanging oblique raise", "Bent-knee wipers"],
    progressions: ["Straighter legs + bigger range", "Slower tempo"],
    youtubeQuery: "hanging windshield wipers strict form",
  ),
  SeedMovementGuide(
    movementId: "tuck_dragon_flag",
    primaryMuscles: ["Abs (anti-extension)"],
    secondaryMuscles: ["Hip flexors", "Lats (bracing)", "Glutes"],
    setup:
        "Hold a sturdy bench/pole behind head. Shoulders pinned. Knees tucked.",
    execution:
        "Lift hips and hold a tucked lever. Keep hips locked and resist arching.",
    cues: ["Hips locked", "Ribs down", "Slow control", "Squeeze glutes"],
    commonMistakes: ["Breaking at hips", "Arching low back", "Using momentum"],
    regressions: ["Reverse crunch (floor)", "Shorter lever tuck"],
    progressions: ["Dragon flag negative", "Dragon flag"],
    youtubeQuery: "tuck dragon flag proper form",
  ),
  SeedMovementGuide(
    movementId: "dragon_flag_negative",
    primaryMuscles: ["Abs (anti-extension)"],
    secondaryMuscles: ["Hip flexors", "Lats (bracing)", "Glutes"],
    setup:
        "Top position supported on bench/pole. Body rigid. Start with knees slightly tucked if needed.",
    execution:
        "Lower slowly keeping a straight line from shoulders to knees/feet (don’t hinge).",
    cues: ["Slow down", "No hip break", "Glutes on", "Control end range"],
    commonMistakes: [
      "Bending at hips",
      "Dropping fast",
      "Losing shoulder position",
    ],
    regressions: ["Tuck dragon flag"],
    progressions: ["Full dragon flag reps"],
    youtubeQuery: "dragon flag negative strict form no hip bend",
  ),
  SeedMovementGuide(
    movementId: "dragon_flag",
    primaryMuscles: ["Abs (anti-extension)"],
    secondaryMuscles: ["Hip flexors", "Lats (bracing)", "Glutes"],
    setup: "Strong negative first. Grip solid behind head. Shoulders pinned.",
    execution:
        "Lower under control and raise back up without hinging at the hips.",
    cues: ["Whole body rigid", "Glutes tight", "Slow eccentric", "No hip bend"],
    commonMistakes: ["Kicking up", "Hinging", "Short range", "Neck strain"],
    regressions: ["Dragon flag negatives", "Tuck dragon flag"],
    progressions: ["Slower tempo", "More reps/sets"],
    youtubeQuery: "full dragon flag strict form tutorial",
  ),
  SeedMovementGuide(
    movementId: "pike_compression",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Quads", "Hamstrings (length)"],
    setup: "Seated pike. Hands by hips. Sit tall, knees straight if possible.",
    execution:
        "Lift heels/legs slightly off floor without leaning back excessively.",
    cues: [
      "Sit tall",
      "Pull toes up",
      "Lift from hip flexors",
      "Small lifts count",
    ],
    commonMistakes: [
      "Leaning back to cheat",
      "Bending knees",
      "Shrugging shoulders",
    ],
    regressions: ["Bent-knee pike lifts", "Hands further forward"],
    progressions: ["Seated pike lift", "Press handstand drills"],
    youtubeQuery: "seated pike compression lifts proper form",
  ),
  SeedMovementGuide(
    movementId: "seated_pike_lift",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Quads", "Shoulders (depression)", "Triceps"],
    setup:
        "Hands by hips (or slightly behind) on floor/parallettes. Push shoulders down.",
    execution:
        "Lift both straight legs off the floor and hold briefly, then lower with control.",
    cues: ["Shoulders down", "Lock elbows", "Legs together", "No momentum"],
    commonMistakes: ["Leaning back hard", "Bending knees", "Using a bounce"],
    regressions: ["Pike compression", "One-leg lift"],
    progressions: ["Straddle compression lift", "Tuck press handstand"],
    youtubeQuery: "seated pike lift compression strict",
  ),
  SeedMovementGuide(
    movementId: "straddle_compression",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Adductors (length/control)", "Quads"],
    setup: "Seated straddle. Hands in front or by hips on blocks.",
    execution: "Lift both legs in straddle. Keep torso tall and avoid rocking.",
    cues: ["Tall posture", "Toes up", "Lift + hold", "Control down"],
    commonMistakes: ["Rocking back", "Bending knees", "Tiny uncontrolled reps"],
    regressions: ["One-leg straddle lifts", "Hands further forward"],
    progressions: ["Straddle press handstand"],
    youtubeQuery: "straddle compression lift proper form",
  ),

  // =========================
  // PUSH
  // =========================
  SeedMovementGuide(
    movementId: "incline_push_up",
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front delts", "Core"],
    setup: "Hands on elevated surface. Body straight, abs + glutes tight.",
    execution:
        "Lower chest to surface, press to full lockout without losing body line.",
    cues: [
      "Body in one line",
      "Elbows 30-45 deg",
      "Full lockout",
      "Control down",
    ],
    commonMistakes: [
      "Hips sagging",
      "Half reps",
      "Elbows flaring hard",
      "Shoulders shrugged",
    ],
    regressions: ["Higher incline"],
    progressions: ["Knee push-up", "Push-up"],
    youtubeQuery: "incline push up proper form",
  ),
  SeedMovementGuide(
    movementId: "knee_push_up",
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front delts", "Core"],
    setup:
        "Hands under shoulders. Knees on floor. Straight line knees-to-head.",
    execution:
        "Lower chest close to floor, press to full lockout. Keep ribs down.",
    cues: [
      "Ribs down",
      "Elbows 30-45 deg",
      "Full range",
      "Squeeze glutes lightly",
    ],
    commonMistakes: ["Hips bending", "Half reps", "Elbows flaring"],
    regressions: ["Incline push-up"],
    progressions: ["Push-up"],
    youtubeQuery: "knee push up correct form full range",
  ),
  SeedMovementGuide(
    movementId: "push_up",
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front delts", "Core"],
    setup:
        "Hands under shoulders, feet together or shoulder-width. Brace abs + glutes.",
    execution:
        "Lower with elbows about 30-45 deg from body. Chest close to floor, then press to full lockout.",
    cues: ["Ribs down", "Squeeze glutes", "One line body", "Full lockout"],
    commonMistakes: [
      "Hips sagging",
      "Elbows flaring hard",
      "Half reps",
      "Head dropping",
    ],
    regressions: ["Incline push-up", "Knee push-up"],
    progressions: ["Diamond push-up", "Decline push-up"],
    youtubeQuery: "push up proper form calisthenics tutorial",
  ),
  SeedMovementGuide(
    movementId: "diamond_push_up",
    primaryMuscles: ["Triceps"],
    secondaryMuscles: ["Chest", "Front delts", "Core"],
    setup: "Hands close (diamond/triangle). Keep shoulders down and stable.",
    execution: "Lower under control, elbows track back. Press to lockout.",
    cues: ["Elbows in", "Body rigid", "Full depth", "Lockout"],
    commonMistakes: [
      "Shoulders collapsing forward",
      "Elbows flaring",
      "Short reps",
    ],
    regressions: ["Close-grip push-up", "Incline diamond"],
    progressions: ["Parallel bar dip", "Ring triceps extension"],
    youtubeQuery: "diamond push up strict form triceps",
  ),
  SeedMovementGuide(
    movementId: "decline_push_up",
    primaryMuscles: ["Chest (upper)", "Front delts"],
    secondaryMuscles: ["Triceps", "Core"],
    setup: "Feet elevated on box/bench. Hands under shoulders. Brace hard.",
    execution:
        "Lower chest between hands, press up to full lockout without piking hips.",
    cues: ["Ribs down", "No hip pike", "Elbows 30-45 deg", "Control down"],
    commonMistakes: [
      "Hips piked",
      "Half reps",
      "Elbows flaring",
      "Neck craning",
    ],
    regressions: ["Push-up", "Lower elevation"],
    progressions: ["Archer push-up", "Pike push-up"],
    youtubeQuery: "decline push up correct form",
  ),
  SeedMovementGuide(
    movementId: "archer_push_up",
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front delts", "Core", "Serratus"],
    setup:
        "Wide hand position. One arm stays straighter while the other does most work.",
    execution:
        "Shift toward working arm, lower with control, press back to center and alternate.",
    cues: [
      "Control the shift",
      "Hips square",
      "Working elbow 30-45 deg",
      "Full range",
    ],
    commonMistakes: [
      "Twisting hips",
      "Bouncing",
      "Short range",
      "Shoulder shrugging",
    ],
    regressions: ["Wide push-up", "Hands elevated archer"],
    progressions: ["Pseudo planche push-up", "Typewriter push-up (later)"],
    youtubeQuery: "archer push up proper form",
  ),
  SeedMovementGuide(
    movementId: "pseudo_planche_push_up",
    primaryMuscles: ["Front delts", "Chest"],
    secondaryMuscles: ["Triceps", "Serratus", "Core", "Wrists"],
    setup:
        "Hands turned out slightly, shoulders leaned forward past wrists. Body hollow.",
    execution:
        "Lower keeping lean, press up without losing protraction and body tension.",
    cues: [
      "Lean forward",
      "Protract (push away)",
      "Ribs down",
      "Straight-ish line",
    ],
    commonMistakes: [
      "Losing lean at bottom",
      "Elbows flaring",
      "Hips sagging",
      "Wrist pain from rushing",
    ],
    regressions: ["Planche lean hold", "Feet wider", "Incline pseudo planche"],
    progressions: ["Planche lean deeper", "Tuck planche"],
    youtubeQuery: "pseudo planche push up strict form",
  ),
  SeedMovementGuide(
    movementId: "support_hold",
    primaryMuscles: ["Triceps (lockout)", "Shoulders (depression)"],
    secondaryMuscles: ["Core", "Chest"],
    setup: "Top of dip on bars/rings. Elbows locked. Body hollow.",
    execution: "Hold steady with shoulders down and rings/bars quiet.",
    cues: ["Lock elbows", "Shoulders down", "Ribs down", "Stay tall"],
    commonMistakes: [
      "Bent elbows",
      "Shrugging",
      "Rings drifting wide",
      "Arching ribs",
    ],
    regressions: ["Assisted support (feet)", "Shorter holds"],
    progressions: ["Parallel bar dip", "Ring support hold"],
    youtubeQuery: "support hold dip bars proper form shoulder depression",
  ),
  SeedMovementGuide(
    movementId: "parallel_dip",
    primaryMuscles: ["Triceps", "Chest"],
    secondaryMuscles: ["Front delts", "Shoulders (stability)", "Core"],
    setup: "Top support on parallel bars. Elbows locked, shoulders down.",
    execution:
        "Lower until shoulders slightly below elbows (pain-free), then press to full lockout.",
    cues: ["Elbows track", "Chest proud", "Full lockout", "No shoulder shrug"],
    commonMistakes: [
      "Shoulders rolling forward",
      "Half reps",
      "Flaring elbows wide",
      "Bouncing bottom",
    ],
    regressions: ["Support hold", "Negative dips"],
    progressions: ["Ring dip", "Bar muscle-up (carryover)"],
    youtubeQuery: "parallel bar dip strict form",
  ),
  SeedMovementGuide(
    movementId: "pike_push_up",
    primaryMuscles: ["Shoulders (delts)"],
    secondaryMuscles: ["Triceps", "Upper chest", "Core"],
    setup: "Hands shoulder-width. Hips high. Head moves between hands.",
    execution: "Lower head toward floor, then press back up keeping hips high.",
    cues: ["Stack shoulders", "Head through", "Control down", "Lockout"],
    commonMistakes: [
      "Turning it into push-up",
      "Elbows flaring",
      "Short depth",
      "Hips dropping",
    ],
    regressions: ["Feet closer in", "Hands elevated"],
    progressions: ["Elevated pike push-up", "Wall HSPU negative"],
    youtubeQuery: "pike push up proper form shoulders",
  ),
  SeedMovementGuide(
    movementId: "elevated_pike_push_up",
    primaryMuscles: ["Shoulders (delts)"],
    secondaryMuscles: ["Triceps", "Upper chest", "Core"],
    setup: "Feet elevated on box. Hands on floor. Hips high.",
    execution:
        "Lower head between hands, press up to lockout. Keep controlled tempo.",
    cues: [
      "More vertical torso",
      "Elbows 30-45 deg",
      "Full range",
      "No collapsing",
    ],
    commonMistakes: [
      "Hips dropping",
      "Partial reps",
      "Flaring elbows",
      "Neck craning",
    ],
    regressions: ["Pike push-up", "Lower elevation"],
    progressions: ["Wall handstand", "Wall HSPU negative"],
    youtubeQuery: "elevated pike push up strict form",
  ),

  // =========================
  // PULL
  // =========================
  SeedMovementGuide(
    movementId: "active_hang",
    primaryMuscles: ["Lats (scap depression)"],
    secondaryMuscles: ["Lower traps", "Forearms", "Rotator cuff"],
    setup: "Hang from bar. Hands just outside shoulder-width.",
    execution:
        "Pull shoulders down away from ears (active hang) and hold without bending elbows much.",
    cues: ["Shoulders down", "Long neck", "Stay still", "Breathe"],
    commonMistakes: ["Shrugging", "Over-bending elbows", "Swinging"],
    regressions: ["Dead hang short holds", "Feet-assisted hang"],
    progressions: ["Scapular pull-up", "Pull-up"],
    youtubeQuery: "active hang scapular depression proper form",
  ),
  SeedMovementGuide(
    movementId: "scap_pull_up",
    primaryMuscles: ["Lats (scap depression)", "Lower traps"],
    secondaryMuscles: ["Mid traps", "Rotator cuff", "Forearms"],
    setup: "Start in dead hang. Elbows straight.",
    execution:
        "Pull shoulders down/back slightly to lift body a few cm, then return slow.",
    cues: [
      "Straight elbows",
      "Shoulders down",
      "Small range",
      "Control both ways",
    ],
    commonMistakes: ["Bending elbows", "Swinging", "Rushing reps"],
    regressions: ["Active hang holds"],
    progressions: ["Negative pull-up", "Pull-up"],
    youtubeQuery: "scapular pull up proper form",
  ),
  SeedMovementGuide(
    movementId: "australian_pull_up",
    primaryMuscles: ["Mid-back", "Lats"],
    secondaryMuscles: ["Biceps", "Rear delts", "Core"],
    setup: "Bar/rings at hip height. Body straight. Heels on floor.",
    execution: "Pull chest to bar/rings, pause, lower under control.",
    cues: [
      "Squeeze shoulder blades",
      "Body rigid",
      "Chest to bar",
      "Control down",
    ],
    commonMistakes: [
      "Hips sagging",
      "Half reps",
      "Shrugging shoulders",
      "Neck craning",
    ],
    regressions: ["Higher bar angle", "Bend knees"],
    progressions: ["Negative pull-up", "Ring row"],
    youtubeQuery: "australian row bodyweight row proper form",
  ),
  SeedMovementGuide(
    movementId: "negative_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup: "Jump/step to top position with chin over bar. Shoulders down.",
    execution: "Lower slowly to full hang. Keep body controlled (no drop).",
    cues: ["Slow descent", "Chest up", "Shoulders down", "Full hang finish"],
    commonMistakes: [
      "Dropping fast",
      "Shrugging",
      "Half range",
      "Kicking legs",
    ],
    regressions: ["Australian row", "Band-assisted negatives"],
    progressions: ["Chin-up", "Pull-up"],
    youtubeQuery: "negative pull up slow eccentric form",
  ),
  SeedMovementGuide(
    movementId: "chin_up",
    primaryMuscles: ["Biceps", "Lats"],
    secondaryMuscles: ["Mid-back", "Forearms"],
    setup: "Underhand grip about shoulder-width. Start from active hang.",
    execution: "Pull chin over bar, pause, lower under control to full hang.",
    cues: ["Shoulders down", "Chest up", "No swing", "Full range"],
    commonMistakes: ["Kipping", "Half reps", "Shrugging", "Neck craning"],
    regressions: ["Negative pull-up"],
    progressions: ["Pull-up", "Explosive pull-up"],
    youtubeQuery: "strict chin up form full range",
  ),
  SeedMovementGuide(
    movementId: "pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup:
        "Grip just outside shoulder-width. Start in active hang (shoulders down).",
    execution:
        "Pull chest up toward bar, pause briefly, lower under control to full hang.",
    cues: ["Shoulders down", "Chest up", "No swinging", "Full range"],
    commonMistakes: ["Shrugging", "Kipping", "Half reps", "Neck craning"],
    regressions: ["Australian row", "Negative pull-up"],
    progressions: ["Explosive pull-up", "Archer pull-up"],
    youtubeQuery: "strict pull up form scapular depression",
  ),
  SeedMovementGuide(
    movementId: "explosive_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup: "Strict pull-up base first. Start dead still in active hang.",
    execution:
        "Pull fast and high (aim lower chest to bar). Lower controlled and reset.",
    cues: ["Explode up", "No swing", "Pull elbows down", "Reset each rep"],
    commonMistakes: [
      "Kipping",
      "Half range",
      "Dropping too fast",
      "Overarching",
    ],
    regressions: ["Pull-up", "Band-assisted explosive"],
    progressions: ["Muscle-up transition", "Bar muscle-up"],
    youtubeQuery: "explosive pull up chest to bar strict",
  ),
  SeedMovementGuide(
    movementId: "archer_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup: "Wide grip. One arm bends more while the other stays straighter.",
    execution:
        "Pull toward one hand, keep the other arm long-ish. Alternate sides with control.",
    cues: ["Control side shift", "Shoulders down", "Full range", "No swinging"],
    commonMistakes: [
      "Twisting hard",
      "Kipping",
      "Losing scap position",
      "Tiny range",
    ],
    regressions: ["Pull-up", "Assisted archer (band)"],
    progressions: ["Typewriter pull-up", "Uneven pull-up"],
    youtubeQuery: "archer pull up proper form",
  ),
  SeedMovementGuide(
    movementId: "typewriter_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup:
        "Pull to top position and hold near the bar with strong scap depression.",
    execution:
        "Move side-to-side along the bar (or between hands) while staying high.",
    cues: [
      "Stay high",
      "Slow side travel",
      "Shoulders down",
      "Control the transition",
    ],
    commonMistakes: [
      "Dropping between sides",
      "Swinging",
      "Neck craning",
      "Rushing",
    ],
    regressions: ["Archer pull-up"],
    progressions: ["Uneven pull-up", "One-arm lock-off"],
    youtubeQuery: "typewriter pull up strict form",
  ),
  SeedMovementGuide(
    movementId: "uneven_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Forearms", "Mid-back"],
    setup: "One hand higher/lower (towel/strap assist). Keep shoulders packed.",
    execution:
        "Pull up emphasizing the lower hand. Lower slowly and keep body quiet.",
    cues: [
      "Lower hand does more",
      "No twisting",
      "Slow eccentric",
      "Shoulders down",
    ],
    commonMistakes: [
      "Twisting",
      "Kipping",
      "Letting shoulder shrug",
      "Half reps",
    ],
    regressions: ["Typewriter/archer variations", "More assistance"],
    progressions: ["One-arm lock-off", "One-arm negative pull-up"],
    youtubeQuery: "uneven pull up one arm progression form",
  ),
  SeedMovementGuide(
    movementId: "one_arm_hang",
    primaryMuscles: ["Forearms (grip)"],
    secondaryMuscles: ["Lats", "Rotator cuff", "Lower traps"],
    setup:
        "Start two-hand hang, shift weight, then release one hand. Shoulder packed.",
    execution: "Hold without shrugging. Keep ribs down and avoid twisting.",
    cues: ["Shoulder down", "Long neck", "Stay still", "Breathe"],
    commonMistakes: [
      "Shrugging",
      "Painful shoulder position",
      "Swinging",
      "Overdoing volume too fast",
    ],
    regressions: ["Assisted one-arm hang (finger support)", "Short holds"],
    progressions: ["One-arm lock-off", "Weighted hangs (later)"],
    youtubeQuery: "one arm hang scapular depression proper form",
  ),
  SeedMovementGuide(
    movementId: "one_arm_lockoff",
    primaryMuscles: ["Lats", "Biceps"],
    secondaryMuscles: ["Forearms", "Mid-back", "Core"],
    setup:
        "Get to top/mid position using both hands or assistance. Shoulder packed.",
    execution:
        "Release one hand and hold the lock-off position (top or 90 deg).",
    cues: ["Shoulder down", "Elbow angle fixed", "No twisting", "Breathe"],
    commonMistakes: [
      "Shoulder shrugging",
      "Twisting body",
      "Holding too long with bad form",
    ],
    regressions: ["Uneven pull-up holds", "Assisted lock-off"],
    progressions: ["One-arm pull-up negative", "One-arm pull-up"],
    youtubeQuery: "one arm lock off hold form",
  ),
  SeedMovementGuide(
    movementId: "one_arm_negative_pull_up",
    primaryMuscles: ["Lats", "Biceps"],
    secondaryMuscles: ["Forearms", "Mid-back", "Core"],
    setup: "Start at the top using assistance. Shoulder packed, body tight.",
    execution: "Lower as slowly as possible on one arm without twisting.",
    cues: ["Slow eccentric", "Shoulder down", "No twist", "Control to hang"],
    commonMistakes: [
      "Dropping fast",
      "Twisting",
      "Shrugging",
      "Cheating start position",
    ],
    regressions: ["One-arm lock-off", "More assistance (towel/strap)"],
    progressions: ["One-arm pull-up"],
    youtubeQuery: "one arm pull up negative proper form",
  ),
  SeedMovementGuide(
    movementId: "one_arm_pull_up",
    primaryMuscles: ["Lats", "Biceps"],
    secondaryMuscles: ["Forearms", "Mid-back", "Core"],
    setup: "Strong lock-off + negatives first. Start from active hang.",
    execution:
        "Pull smoothly to chin over bar on one arm. Lower controlled to full hang.",
    cues: ["Shoulder down", "No twist", "Smooth pull", "Full range"],
    commonMistakes: [
      "Kipping",
      "Twisting hard",
      "Half reps",
      "Overuse/too much volume",
    ],
    regressions: ["One-arm negatives", "Assisted one-arm pull-up"],
    progressions: ["Cleaner reps", "Paused reps"],
    youtubeQuery: "one arm pull up strict form tutorial",
  ),

  // =========================
  // LEGS
  // =========================
  SeedMovementGuide(
    movementId: "bodyweight_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Adductors", "Calves", "Core"],
    setup: "Feet shoulder-width. Toes slightly out. Brace lightly.",
    execution:
        "Sit down and back to comfortable depth. Drive up through midfoot.",
    cues: ["Knees track toes", "Chest tall", "Heels down", "Control depth"],
    commonMistakes: [
      "Knees caving in",
      "Heels lifting",
      "Rounding hard",
      "Bouncing",
    ],
    regressions: ["Box squat", "Partial range"],
    progressions: ["Split squat", "Tempo squats"],
    youtubeQuery: "bodyweight squat proper form knees track toes",
  ),
  SeedMovementGuide(
    movementId: "split_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Calves", "Adductors", "Core"],
    setup: "Staggered stance. Front foot flat. Torso tall.",
    execution:
        "Lower straight down until back knee is near floor. Press back up.",
    cues: [
      "Front knee tracks toes",
      "Torso tall",
      "Control down",
      "Push through front foot",
    ],
    commonMistakes: ["Front heel lifting", "Leaning forward", "Wobbling knee"],
    regressions: ["Smaller range", "Assisted balance"],
    progressions: ["Bulgarian split squat", "Shrimp squat"],
    youtubeQuery: "split squat bodyweight proper form",
  ),
  SeedMovementGuide(
    movementId: "reverse_lunge",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings", "Core"],
    setup:
        "Stand tall with feet hip-width. Brace core and keep front foot grounded.",
    execution:
        "Step back into lunge, lower with control, then drive through front leg to stand.",
    cues: [
      "Front heel down",
      "Torso tall",
      "Knee tracks toes",
      "Controlled step back",
    ],
    commonMistakes: [
      "Front knee caving",
      "Pushing off back foot too hard",
      "Leaning forward",
    ],
    regressions: ["Shorter range", "Split squat hold"],
    progressions: ["Bulgarian split squat", "Jump lunge (later)"],
    youtubeQuery: "reverse lunge bodyweight proper form",
  ),
  SeedMovementGuide(
    movementId: "bulgarian_split_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Adductors", "Calves", "Core"],
    setup: "Back foot elevated on bench. Front foot far enough for good depth.",
    execution:
        "Lower under control, back knee toward floor. Drive up through front leg.",
    cues: [
      "Front heel down",
      "Torso tall",
      "Knee tracks toes",
      "Control balance",
    ],
    commonMistakes: ["Front foot too close", "Knee caving", "Bouncing bottom"],
    regressions: ["Split squat"],
    progressions: ["Shrimp squat", "Assisted pistol squat"],
    youtubeQuery: "bulgarian split squat bodyweight proper form",
  ),
  SeedMovementGuide(
    movementId: "cossack_squat",
    primaryMuscles: ["Adductors", "Glutes", "Quads"],
    secondaryMuscles: ["Hamstrings", "Calves", "Core"],
    setup: "Take a wide stance. Toes can turn out slightly. Keep chest proud.",
    execution:
        "Lower deeply into one side while the other leg stays straight. Push through heel to switch sides.",
    cues: [
      "Chest up",
      "Heel down",
      "Sit into hip",
      "Smooth side-to-side control",
    ],
    commonMistakes: ["Rounding back", "Knee collapsing", "Bouncing at bottom"],
    regressions: ["Cossack squat mobility", "Supported range"],
    progressions: ["Deeper reps", "Tempo Cossacks"],
    youtubeQuery: "cossack squat strict form side to side squat",
  ),
  SeedMovementGuide(
    movementId: "shrimp_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Core", "Calves"],
    setup:
        "Hold one foot behind you. Keep hips square. Use light support if needed.",
    execution:
        "Lower with control, knee forward, maintain balance. Stand back up smoothly.",
    cues: ["Control knee", "Stay tall", "Slow down", "Use support if needed"],
    commonMistakes: ["Knee collapsing", "Falling into bottom", "Twisting hips"],
    regressions: ["Assisted shrimp", "Bulgarian split squat"],
    progressions: ["Assisted pistol squat", "Pistol squat"],
    youtubeQuery: "shrimp squat progression proper form",
  ),
  SeedMovementGuide(
    movementId: "jump_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Calves", "Core"],
    setup:
        "Start from athletic stance. Brace lightly and keep knees tracking toes.",
    execution:
        "Squat to controlled depth, explode upward, and land softly into next rep.",
    cues: [
      "Explode up",
      "Soft landing",
      "Knees track toes",
      "Reset balance each rep",
    ],
    commonMistakes: [
      "Hard noisy landings",
      "Knees collapsing inward",
      "Shallow pogo reps",
    ],
    regressions: ["Bodyweight squat", "Low-amplitude jump squat"],
    progressions: ["Pause jump squat", "Broad jump work"],
    youtubeQuery: "jump squat landing mechanics proper form",
  ),
  SeedMovementGuide(
    movementId: "shrimp_squat_negative",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Core", "Calves"],
    setup:
        "Balance on one leg and hold rear foot. Use support lightly if needed.",
    execution:
        "Lower slowly for 3-5 seconds to the bottom with full control, then reset.",
    cues: ["Slow eccentric", "Stay tall", "Knee tracks toes", "Own the bottom"],
    commonMistakes: [
      "Dropping fast",
      "Twisting hips",
      "Collapsing knee inward",
    ],
    regressions: ["Assisted shrimp eccentric", "Bulgarian split squat"],
    progressions: ["Shrimp squat", "Assisted pistol squat"],
    youtubeQuery: "shrimp squat negative proper form",
  ),
  SeedMovementGuide(
    movementId: "assisted_pistol_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Core", "Calves", "Hip flexors"],
    setup:
        "Hold a pole/ring/doorframe. Extend one leg forward. Keep heel down.",
    execution:
        "Lower slowly to depth you control, then stand. Keep knee tracking toes.",
    cues: ["Heel down", "Knee tracks toes", "Control descent", "Stay balanced"],
    commonMistakes: [
      "Heel lifting",
      "Knee cave",
      "Collapsing into bottom",
      "Rounding hard",
    ],
    regressions: ["Shrimp squat", "Box pistol"],
    progressions: ["Pistol squat"],
    youtubeQuery: "assisted pistol squat proper form",
  ),
  SeedMovementGuide(
    movementId: "pistol_squat",
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Core", "Calves", "Hip flexors"],
    setup:
        "One leg extended forward. Stand tall. Brace lightly and focus on balance.",
    execution:
        "Lower under control to full depth if possible. Stand up without bouncing.",
    cues: [
      "Heel down",
      "Knee tracks toes",
      "Slow descent",
      "Stand tall at top",
    ],
    commonMistakes: [
      "Heel lifting",
      "Knee collapsing",
      "Falling into bottom",
      "Using momentum",
    ],
    regressions: ["Assisted pistol squat"],
    progressions: ["Cleaner reps", "Tempo pistols"],
    youtubeQuery: "pistol squat strict form tutorial",
  ),

  // =========================
  // SKILLS (HANDSTAND / LEVERS / MUSCLE-UP / FLAG / PLANCHE)
  // =========================
  SeedMovementGuide(
    movementId: "wall_handstand",
    primaryMuscles: ["Shoulders (stability)"],
    secondaryMuscles: ["Triceps", "Upper back", "Core", "Forearms/wrists"],
    setup:
        "Chest-to-wall. Hands shoulder-width. Fingers spread. Brace ribs down.",
    execution:
        "Stack wrists-shoulders-hips-ankles. Hold with active shoulders and calm breathing.",
    cues: ["Push tall", "Ribs down", "Glutes on", "Look at floor"],
    commonMistakes: [
      "Banana back (rib flare)",
      "Shrugging into ears",
      "Hands too wide",
      "Overarching neck",
    ],
    regressions: ["Wall handstand (belly-to-wall)", "Pike hold on box"],
    progressions: ["Freestanding handstand", "Wall HSPU negative"],
    youtubeQuery: "chest to wall handstand alignment cues",
  ),
  SeedMovementGuide(
    movementId: "freestanding_handstand",
    primaryMuscles: ["Shoulders (stability)"],
    secondaryMuscles: ["Triceps", "Core", "Upper back", "Forearms/wrists"],
    setup:
        "Warm wrists. Practice wall line first. Hands shoulder-width, fingers active.",
    execution:
        "Kick up (or press) into balance. Make small finger pressure corrections and stay stacked.",
    cues: ["Stacked line", "Squeeze glutes", "Push tall", "Breathe"],
    commonMistakes: [
      "Overkicking",
      "Banana shape",
      "Looking forward too much",
      "Collapsing shoulders",
    ],
    regressions: ["Wall handstand holds", "Freestanding toe taps off wall"],
    progressions: ["Longer holds", "Handstand push-up negatives"],
    youtubeQuery: "freestanding handstand balance drills correct form",
  ),
  SeedMovementGuide(
    movementId: "wall_hspu_negative",
    primaryMuscles: ["Shoulders (delts)"],
    secondaryMuscles: ["Triceps", "Upper chest", "Core"],
    setup:
        "Wall handstand. Hands slightly wider than shoulders. Head path between hands.",
    execution:
        "Lower slowly until head gently touches (or to comfortable depth). Return via feet down or partial press.",
    cues: ["Slow descent", "Elbows 30-45 deg", "Push tall", "Ribs down"],
    commonMistakes: [
      "Collapsing at bottom",
      "Flaring elbows",
      "Banana back",
      "Too fast",
    ],
    regressions: ["Elevated pike push-up", "Partial range negatives"],
    progressions: ["Wall HSPU"],
    youtubeQuery: "handstand push up negative wall strict form",
  ),
  SeedMovementGuide(
    movementId: "wall_hspu",
    primaryMuscles: ["Shoulders (delts)"],
    secondaryMuscles: ["Triceps", "Upper chest", "Core"],
    setup: "Stable wall handstand. Hands set. Control your line before reps.",
    execution:
        "Lower to head touch (or depth), press back up to lockout without kipping.",
    cues: ["No kip", "Elbows 30-45 deg", "Full lockout", "Ribs down"],
    commonMistakes: [
      "Bouncing off head",
      "Kipping",
      "Elbows flaring",
      "Losing line",
    ],
    regressions: ["Wall HSPU negatives", "Elevated pike push-up"],
    progressions: ["Freestanding deficit work (later)"],
    youtubeQuery: "wall handstand push up strict form",
  ),

  SeedMovementGuide(
    movementId: "tuck_press_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Triceps", "Upper back"],
    setup:
        "Start in a stable handstand or from a tuck on floor with strong compression.",
    execution:
        "Shift shoulders forward, compress knees to chest, and press into handstand with control.",
    cues: ["Shoulders forward", "Compress hard", "Push tall", "Slow control"],
    commonMistakes: [
      "Jumping/kicking",
      "Losing shoulder lean",
      "Arching ribs",
      "Bent elbows",
    ],
    regressions: ["Seated pike lift", "Wall tuck press drills"],
    progressions: ["Straddle press handstand"],
    youtubeQuery: "tuck press handstand technique compression",
  ),
  SeedMovementGuide(
    movementId: "straddle_press_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Adductors", "Triceps"],
    setup:
        "Good pancake + straddle compression. Hands planted, shoulders over hands.",
    execution:
        "Lean shoulders forward and press straddle legs up into handstand without jumping.",
    cues: ["Lean forward", "Compress", "Push tall", "Slow"],
    commonMistakes: [
      "Jumping",
      "Bent elbows",
      "Closing straddle too early",
      "Rib flare",
    ],
    regressions: ["Tuck press handstand", "Straddle compression lift"],
    progressions: ["Press handstand"],
    youtubeQuery: "straddle press handstand tutorial form",
  ),
  SeedMovementGuide(
    movementId: "press_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Hamstrings", "Triceps"],
    setup:
        "Strong pike compression + handstand balance. Warm wrists and shoulders.",
    execution:
        "From pike, shift shoulders forward and press legs up smoothly into handstand.",
    cues: ["Shoulders forward", "Compress", "Push tall", "No jump"],
    commonMistakes: ["Jumping/kicking", "Bent arms", "Arching ribs", "Rushing"],
    regressions: ["Straddle press", "Tuck press"],
    progressions: ["Cleaner tempo", "Deficit press (later)"],
    youtubeQuery: "press to handstand strict pike press technique",
  ),
  SeedMovementGuide(
    movementId: "l_sit_to_tuck_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Triceps", "Upper back"],
    setup:
        "Own a clean L-sit and tuck press mechanics first. Warm wrists and shoulders.",
    execution:
        "Start in L-sit, lean shoulders forward, compress knees in, and press into a stable tuck handstand.",
    cues: ["Shoulders forward", "Compress hard", "No jump", "Pause control"],
    commonMistakes: [
      "Kicking for momentum",
      "Bent elbows",
      "Losing compression",
      "Rushing the transition",
    ],
    regressions: ["L-sit holds", "Tuck press handstand"],
    progressions: ["L-sit to handstand"],
    youtubeQuery: "l sit to tuck handstand strict progression",
  ),
  SeedMovementGuide(
    movementId: "l_sit_to_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Triceps", "Upper back"],
    setup: "Start from a strong L-sit with active shoulders and locked elbows.",
    execution:
        "Lean forward and keep legs long as you press from L-sit into handstand without a kick.",
    cues: ["Lean and push", "Legs stay long", "No bounce", "Stack slowly"],
    commonMistakes: [
      "Turning it into a kick-up",
      "Dropping chest",
      "Arched low back",
      "Bent arms under load",
    ],
    regressions: ["L-sit to tuck handstand", "Straddle press handstand"],
    progressions: ["V-sit to handstand"],
    youtubeQuery: "l sit to handstand strict press tutorial",
  ),
  SeedMovementGuide(
    movementId: "v_sit_to_handstand",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Adductors", "Triceps"],
    setup:
        "Build high V-sit compression and a consistent L-sit to handstand first.",
    execution:
        "From V-sit, shift shoulders forward and press legs overhead with no jump or knee bend.",
    cues: [
      "Extreme compression",
      "Shoulders ahead",
      "Push tall",
      "Slow lock-in",
    ],
    commonMistakes: [
      "Losing V-shape early",
      "Jumping to finish",
      "Bending elbows",
      "Rib flare at top",
    ],
    regressions: ["L-sit to handstand", "V-sit holds"],
    progressions: ["Cleaner tempo", "Deficit entries"],
    youtubeQuery: "v sit to handstand strict press form",
  ),
  SeedMovementGuide(
    movementId: "l_sit_to_tuck_planche",
    primaryMuscles: ["Shoulders", "Abs (compression)"],
    secondaryMuscles: ["Hip flexors", "Chest", "Serratus"],
    setup:
        "Start in a clean L-sit with elbows locked and shoulders protracted.",
    execution:
        "Lean forward, keep compression, and shift into tuck planche without hopping feet.",
    cues: ["Lean and protract", "Lock elbows", "Stay compressed", "Slow shift"],
    commonMistakes: [
      "Jumping to planche",
      "Bent elbows",
      "Losing hollow shape",
      "Shoulders drifting back",
    ],
    regressions: ["L-sit to tuck handstand", "Tuck planche holds"],
    progressions: ["Tuck planche to handstand"],
    youtubeQuery: "l sit to tuck planche strict transition",
  ),
  SeedMovementGuide(
    movementId: "tuck_planche_to_handstand",
    primaryMuscles: ["Shoulders", "Triceps"],
    secondaryMuscles: ["Abs", "Serratus", "Upper back"],
    setup: "Own stable tuck planche and controlled tuck press handstand first.",
    execution:
        "From tuck planche, elevate hips and press through shoulders into handstand without leg kick.",
    cues: [
      "Push tall",
      "Shoulders forward then stack",
      "No kick",
      "Control lockout",
    ],
    commonMistakes: [
      "Kicking out of planche",
      "Bending elbows under load",
      "Losing shoulder protraction",
      "Rushing the top position",
    ],
    regressions: ["L-sit to tuck planche", "Tuck press handstand"],
    progressions: ["Straddle variations", "Cleaner tempo"],
    youtubeQuery: "tuck planche to handstand transition strict form",
  ),
  SeedMovementGuide(
    movementId: "l_sit_to_muscle_up_transition",
    primaryMuscles: ["Lats", "Biceps", "Core"],
    secondaryMuscles: ["Forearms", "Chest", "Triceps"],
    setup:
        "Use a high pull setup. Start in controlled L-sit or strong hollow with no swing.",
    execution:
        "Explosively pull from compressed position and rotate through transition close to the bar.",
    cues: ["Stay close to bar", "Explode up", "Fast turnover", "Avoid big kip"],
    commonMistakes: [
      "Swinging/kipping too much",
      "Pulling away from bar",
      "Late transition",
      "Soft lockout",
    ],
    regressions: ["Muscle-up transition drills", "Explosive pull-ups"],
    progressions: ["Front lever to muscle-up"],
    youtubeQuery: "l sit to muscle up transition strict technique",
  ),
  SeedMovementGuide(
    movementId: "front_lever_to_muscle_up",
    primaryMuscles: ["Lats", "Biceps", "Core"],
    secondaryMuscles: ["Forearms", "Rear delts", "Triceps"],
    setup:
        "Build strong front lever holds and strict bar muscle-up mechanics first.",
    execution:
        "Initiate from lever tension and transition into muscle-up path with a fast, close bar line.",
    cues: [
      "Leverage then explode",
      "Bar close",
      "Core tight",
      "Strong turnover",
    ],
    commonMistakes: [
      "Losing body tension first",
      "Arcing away from bar",
      "Slow turnover",
      "Early elbow flare",
    ],
    regressions: ["L-sit to muscle-up transition", "Explosive pull-up"],
    progressions: ["Bar muscle-up to handstand negative"],
    youtubeQuery: "front lever to muscle up strict transition",
  ),
  SeedMovementGuide(
    movementId: "bar_muscle_up_to_handstand_negative",
    primaryMuscles: ["Shoulders", "Triceps", "Core"],
    secondaryMuscles: ["Chest", "Upper back", "Forearms"],
    setup:
        "Start from top support after a clean muscle-up. Keep wrists warm and elbows locked.",
    execution:
        "Lower with control through deep shoulder lean toward handstand line strength.",
    cues: [
      "Slow negative",
      "Push through shoulders",
      "Ribs down",
      "No collapse",
    ],
    commonMistakes: [
      "Dropping too fast",
      "Elbows unlocking early",
      "Shoulders collapsing",
      "Overarching low back",
    ],
    regressions: ["Front lever to muscle-up", "Wall handstand negatives"],
    progressions: ["Longer negatives", "Pause points"],
    youtubeQuery: "bar muscle up to handstand negative control drill",
  ),

  SeedMovementGuide(
    movementId: "tuck_front_lever",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes", "Forearms"],
    setup:
        "Hang from bar/rings. Depress scapula (shoulders down). Tuck knees toward chest.",
    execution:
        "Hold body horizontal-ish with tuck. Maintain hollow (ribs down).",
    cues: ["Shoulders down", "Hollow body", "Hips up", "Stay tight"],
    commonMistakes: ["Shrugging", "Hips dropping", "Arching", "Swinging"],
    regressions: ["Tuck lever with one knee less tucked", "Row variations"],
    progressions: ["Advanced tuck front lever", "Tuck front lever raises"],
    youtubeQuery: "tuck front lever hold proper form scap depression",
  ),
  SeedMovementGuide(
    movementId: "adv_tuck_front_lever",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup: "Start from tuck. Open hips slightly so knees move away from chest.",
    execution: "Hold with hips more open. Keep scap depressed and ribs down.",
    cues: ["Open hips", "Shoulders down", "Stay hollow", "No pike"],
    commonMistakes: ["Piking hips", "Shrugging", "Losing tension"],
    regressions: ["Tuck front lever"],
    progressions: ["Straddle front lever", "Adv tuck raises"],
    youtubeQuery: "advanced tuck front lever correct form",
  ),
  SeedMovementGuide(
    movementId: "straddle_front_lever",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup: "Strong adv tuck first. Straddle legs wide to reduce lever length.",
    execution:
        "Hold body horizontal with straddle legs. Maintain hollow and scap depression.",
    cues: ["Wide straddle", "Shoulders down", "Hips level", "Breathe"],
    commonMistakes: ["Piking", "Shrugging", "Legs drifting", "Swinging"],
    regressions: ["Advanced tuck front lever"],
    progressions: ["Front lever", "Front lever raises"],
    youtubeQuery: "straddle front lever hold proper technique",
  ),
  SeedMovementGuide(
    movementId: "front_lever",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup:
        "Warm shoulders. Strong straddle first. Active hang with scap depression.",
    execution: "Hold full lever horizontal. Keep ribs down and glutes tight.",
    cues: ["Shoulders down", "Hollow", "Glutes on", "Stay horizontal"],
    commonMistakes: ["Arching", "Hips dropping", "Shrugging", "Bending knees"],
    regressions: ["Straddle front lever", "Advanced tuck"],
    progressions: ["Front lever raises", "Longer holds"],
    youtubeQuery: "front lever hold strict form scapula depression",
  ),
  SeedMovementGuide(
    movementId: "tuck_front_lever_raises",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup: "Active hang, tuck position ready. Start still.",
    execution:
        "Raise and lower through lever angle in tuck with control. Avoid swinging.",
    cues: ["No swing", "Shoulders down", "Control both ways", "Stay hollow"],
    commonMistakes: [
      "Kipping",
      "Shrugging",
      "Dropping fast",
      "Losing tuck shape",
    ],
    regressions: ["Tuck front lever hold", "Rows"],
    progressions: ["Adv tuck raises"],
    youtubeQuery: "tuck front lever raises strict form",
  ),
  SeedMovementGuide(
    movementId: "adv_tuck_front_lever_raises",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup: "Advanced tuck shape. Start from hang, still body.",
    execution:
        "Raise and lower through lever angles maintaining open-hip tuck.",
    cues: ["Hips open", "Shoulders down", "No swing", "Slow tempo"],
    commonMistakes: ["Piking", "Swinging", "Shrugging"],
    regressions: ["Tuck front lever raises"],
    progressions: ["Front lever raises"],
    youtubeQuery: "advanced tuck front lever raises proper form",
  ),
  SeedMovementGuide(
    movementId: "front_lever_raises",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Abs", "Mid-back", "Glutes"],
    setup: "Strong front lever hold first. Start dead still.",
    execution:
        "Raise and lower through lever range with full-body tension and control.",
    cues: ["Stay tight", "No swing", "Scap down", "Slow eccentric"],
    commonMistakes: ["Kipping", "Hips dropping", "Losing hollow"],
    regressions: ["Adv tuck raises", "Straddle lever raises"],
    progressions: ["Paused raises", "Higher reps"],
    youtubeQuery: "front lever raises strict form",
  ),

  SeedMovementGuide(
    movementId: "german_hang",
    primaryMuscles: ["Shoulders (extension mobility)"],
    secondaryMuscles: [
      "Chest (stretch)",
      "Biceps tendon tolerance",
      "Lats (stretch)",
    ],
    setup: "Rings/bar. Rotate through carefully. Start supported if needed.",
    execution:
        "Set into German hang with straight-ish arms (as tolerated). Hold pain-free.",
    cues: [
      "Go slow",
      "Shoulders open gradually",
      "Breathe",
      "Stop before pain",
    ],
    commonMistakes: [
      "Forcing range",
      "Sharp shoulder pain",
      "Rushing transitions",
    ],
    regressions: ["Tucked german hang", "Feet-assisted"],
    progressions: ["Skin the cat", "Back lever"],
    youtubeQuery: "german hang rings proper form shoulder extension",
  ),
  SeedMovementGuide(
    movementId: "skin_the_cat",
    primaryMuscles: ["Shoulders (strength + mobility)"],
    secondaryMuscles: ["Lats", "Abs", "Hip flexors"],
    setup: "Hang on rings/bar. Tuck knees. Control the rotation.",
    execution:
        "Rotate through into German hang and back. Move slowly with control.",
    cues: ["Slow rotation", "Tuck tight", "Shoulders controlled", "No bounce"],
    commonMistakes: ["Dropping fast", "Forcing german hang", "Swinging"],
    regressions: ["Tuck rotations", "Feet-assisted"],
    progressions: ["Tuck back lever", "Ring inverted hang"],
    youtubeQuery: "skin the cat strict form rings",
  ),
  SeedMovementGuide(
    movementId: "tuck_back_lever",
    primaryMuscles: ["Shoulders (extension strength)"],
    secondaryMuscles: ["Abs", "Glutes", "Upper back"],
    setup: "From inverted hang/skin-the-cat. Tuck knees. Set shoulders active.",
    execution:
        "Hold tuck back lever with body parallel-ish and glutes engaged.",
    cues: ["Active shoulders", "Glutes on", "Ribs down", "No pike"],
    commonMistakes: ["Piking hips", "Shoulders collapsing", "Bending arms"],
    regressions: ["Skin the cat", "German hang holds"],
    progressions: ["Back lever hold"],
    youtubeQuery: "tuck back lever proper form",
  ),
  SeedMovementGuide(
    movementId: "back_lever",
    primaryMuscles: ["Shoulders (extension strength)"],
    secondaryMuscles: ["Abs", "Glutes", "Upper back"],
    setup: "Strong tuck back lever first. Warm shoulders well.",
    execution:
        "Hold full back lever: straight body line, active shoulders, glutes tight.",
    cues: ["Glutes tight", "Ribs down", "Active shoulders", "Body straight"],
    commonMistakes: [
      "Piking",
      "Bent arms",
      "Shoulders collapsing",
      "Overextending neck",
    ],
    regressions: ["Tuck back lever"],
    progressions: ["Longer holds", "Ring back lever"],
    youtubeQuery: "back lever hold strict form",
  ),

  SeedMovementGuide(
    movementId: "muscle_up_transition",
    primaryMuscles: ["Lats", "Triceps (transition)"],
    secondaryMuscles: ["Chest", "Forearms", "Shoulders"],
    setup: "Use low bar or band assistance if needed. Keep close to bar.",
    execution:
        "Practice pulling high then rotating wrists/elbows over the bar into dip position smoothly.",
    cues: ["Stay close", "Fast turnover", "Elbows over bar", "No chicken wing"],
    commonMistakes: [
      "Too far from bar",
      "Slow turnover",
      "One-arm chicken wing",
      "No dip strength",
    ],
    regressions: ["Explosive pull-up", "Dip strength"],
    progressions: ["Bar muscle-up"],
    youtubeQuery: "muscle up transition drill close to bar",
  ),
  SeedMovementGuide(
    movementId: "bar_muscle_up",
    primaryMuscles: ["Lats", "Chest", "Triceps"],
    secondaryMuscles: ["Forearms", "Shoulders", "Core"],
    setup:
        "Strong explosive pull-up + dip first. Grip solid. Start from still hang.",
    execution:
        "Pull high, transition quickly over bar, finish with strong dip to lockout.",
    cues: [
      "Pull to lower chest",
      "Fast turnover",
      "Keep bar close",
      "Lockout dip",
    ],
    commonMistakes: [
      "Low pull",
      "Chicken wing",
      "Kipping without control",
      "Missing lockout",
    ],
    regressions: ["Transition drills", "Band-assisted muscle-up"],
    progressions: ["Cleaner strict reps", "Higher pulls"],
    youtubeQuery: "bar muscle up strict technique tutorial",
  ),

  SeedMovementGuide(
    movementId: "flag_pole_support",
    primaryMuscles: ["Shoulders (stability)", "Obliques"],
    secondaryMuscles: ["Lats", "Forearms", "Glutes"],
    setup:
        "Hands stacked on pole. Top hand pulls, bottom hand pushes. Shoulders packed.",
    execution: "Hold the support position with hips tight and no twisting.",
    cues: [
      "Top pulls / bottom pushes",
      "Shoulders packed",
      "Hips tight",
      "No rotation",
    ],
    commonMistakes: ["Shrugging", "Loose hips", "Twisting", "Hands too close"],
    regressions: ["Side plank", "Band-assisted support"],
    progressions: ["Tucked human flag"],
    youtubeQuery: "human flag pole support position proper form",
  ),
  SeedMovementGuide(
    movementId: "tucked_human_flag",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Shoulders", "Lats", "Glutes"],
    setup: "From pole support. Tuck knees to shorten lever.",
    execution:
        "Lift hips and hold flag tuck. Keep shoulders packed and hips stacked.",
    cues: ["Push/pull", "Hips high", "Stay tight", "Breathe"],
    commonMistakes: ["Hips dropping", "Twisting", "Shrugging", "Legs opening"],
    regressions: ["Flag pole support"],
    progressions: ["Advanced tuck human flag", "Straddle human flag"],
    youtubeQuery: "tucked human flag hold proper form",
  ),
  SeedMovementGuide(
    movementId: "adv_tuck_human_flag",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Shoulders", "Lats", "Glutes"],
    setup: "From tucked flag, extend hips/knees slightly to increase lever.",
    execution: "Hold advanced tuck with controlled hips and no rotation.",
    cues: ["Hips stacked", "Push/pull hard", "No twist", "Stay rigid"],
    commonMistakes: ["Rotating open", "Hips sagging", "Shrugging"],
    regressions: ["Tucked human flag"],
    progressions: ["Straddle human flag"],
    youtubeQuery: "advanced tuck human flag technique",
  ),
  SeedMovementGuide(
    movementId: "straddle_human_flag",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Shoulders", "Lats", "Glutes"],
    setup: "Hands solid. Start from advanced tuck and open legs to straddle.",
    execution:
        "Hold straddle line. Keep hips from rotating and maintain push/pull tension.",
    cues: ["Wide straddle", "Hips level", "Shoulders packed", "No rotation"],
    commonMistakes: ["Hips turning", "Dropping lower leg", "Shrugging"],
    regressions: ["Advanced tuck flag"],
    progressions: ["Human flag"],
    youtubeQuery: "straddle human flag hold proper form",
  ),
  SeedMovementGuide(
    movementId: "human_flag",
    primaryMuscles: ["Obliques"],
    secondaryMuscles: ["Shoulders", "Lats", "Glutes"],
    setup:
        "Strong straddle first. Hands spaced well. Top pulls, bottom pushes.",
    execution:
        "Hold full straight-body flag. Keep hips stacked and legs together.",
    cues: ["Rigid line", "Push/pull", "Hips stacked", "Breathe"],
    commonMistakes: ["Twisting", "Bent knees", "Shoulders shrug", "Loose core"],
    regressions: ["Straddle human flag"],
    progressions: ["Longer holds", "Cleaner entries"],
    youtubeQuery: "human flag hold strict form tutorial",
  ),

  SeedMovementGuide(
    movementId: "planche_lean",
    primaryMuscles: ["Front delts", "Serratus"],
    secondaryMuscles: ["Wrists", "Abs", "Triceps"],
    setup:
        "Hands on floor/parallettes. Protract (push away). Lean shoulders forward.",
    execution:
        "Hold lean with straight arms and hollow body. Increase lean gradually.",
    cues: ["Straight arms", "Protract", "Lean forward", "Ribs down"],
    commonMistakes: [
      "Bent elbows",
      "Losing protraction",
      "Hips sagging",
      "Wrist pain from rushing",
    ],
    regressions: ["Smaller lean", "Hands on parallettes"],
    progressions: ["Frog stand", "Tuck planche"],
    youtubeQuery: "planche lean proper form protraction straight arms",
  ),
  SeedMovementGuide(
    movementId: "frog_stand",
    primaryMuscles: ["Shoulders", "Serratus"],
    secondaryMuscles: ["Triceps", "Abs", "Wrists"],
    setup: "Hands on floor. Knees on triceps (elbow shelf). Fingers spread.",
    execution: "Lean forward to lift feet. Hold balance with active shoulders.",
    cues: [
      "Look slightly forward",
      "Push floor away",
      "Lean forward",
      "Stay tight",
    ],
    commonMistakes: [
      "Collapsing shoulders",
      "Not leaning enough",
      "Elbows sliding",
    ],
    regressions: ["Toe-assisted frog", "Higher surface"],
    progressions: ["Tuck planche", "Planche lean deeper"],
    youtubeQuery: "frog stand crow pose calisthenics planche prep form",
  ),
  SeedMovementGuide(
    movementId: "tuck_planche",
    primaryMuscles: ["Front delts", "Serratus"],
    secondaryMuscles: ["Triceps", "Abs", "Wrists"],
    setup:
        "From frog stand or planche lean. Protract hard. Tuck knees to chest.",
    execution:
        "Lift knees off arms (if possible) and hold tuck planche with straight arms.",
    cues: ["Protract hard", "Straight arms", "Lean forward", "Hollow"],
    commonMistakes: [
      "Bent arms",
      "Shoulders collapsing",
      "Hips too low",
      "Looking forward too much",
    ],
    regressions: ["Frog stand", "Planche lean"],
    progressions: ["Advanced tuck planche"],
    youtubeQuery: "tuck planche hold proper form straight arm",
  ),
  SeedMovementGuide(
    movementId: "adv_tuck_planche",
    primaryMuscles: ["Front delts", "Serratus"],
    secondaryMuscles: ["Triceps", "Abs", "Wrists"],
    setup:
        "From tuck planche. Open hips slightly so knees move away from chest.",
    execution: "Hold advanced tuck with straight arms and strong protraction.",
    cues: ["Open hips", "Protract", "Lean forward", "Stay hollow"],
    commonMistakes: [
      "Piking",
      "Bent elbows",
      "Losing protraction",
      "Hips dropping",
    ],
    regressions: ["Tuck planche"],
    progressions: ["Straddle planche"],
    youtubeQuery: "advanced tuck planche strict form",
  ),
  SeedMovementGuide(
    movementId: "straddle_planche",
    primaryMuscles: ["Front delts", "Serratus"],
    secondaryMuscles: ["Triceps", "Abs", "Wrists"],
    setup: "Strong adv tuck first. Straddle legs wide to reduce lever.",
    execution:
        "Hold straddle planche with straight arms, protraction, and hollow body.",
    cues: ["Wide straddle", "Protract", "Lean forward", "Straight elbows"],
    commonMistakes: [
      "Bent arms",
      "Losing hollow",
      "Legs drifting",
      "Shoulders collapsing",
    ],
    regressions: ["Advanced tuck planche"],
    progressions: ["Planche"],
    youtubeQuery: "straddle planche hold correct form",
  ),
  SeedMovementGuide(
    movementId: "planche",
    primaryMuscles: ["Front delts", "Serratus"],
    secondaryMuscles: ["Triceps", "Abs", "Wrists"],
    setup: "Warm wrists + shoulders. Strong straddle planche first.",
    execution:
        "Hold full planche: straight body, straight arms, strong protraction.",
    cues: ["Straight arms", "Protract", "Hollow body", "Lean forward"],
    commonMistakes: [
      "Bent elbows",
      "Sagging hips",
      "Losing protraction",
      "Rib flare",
    ],
    regressions: ["Straddle planche", "Advanced tuck planche"],
    progressions: ["Longer holds", "Planche push-ups (later)"],
    youtubeQuery: "full planche hold strict technique",
  ),

  // =========================
  // RINGS
  // =========================
  SeedMovementGuide(
    movementId: "ring_support_assisted",
    primaryMuscles: ["Triceps (lockout)", "Shoulders (depression)"],
    secondaryMuscles: ["Core", "Chest"],
    setup:
        "Rings at sides. Feet lightly on floor or band support. Elbows locked.",
    execution:
        "Hold stable support with rings close to body and shoulders down.",
    cues: [
      "Lock elbows",
      "Turn pits forward slightly",
      "Rings close",
      "Stay tall",
    ],
    commonMistakes: [
      "Bent elbows",
      "Rings drifting out",
      "Shrugging",
      "Overarching ribs",
    ],
    regressions: ["More foot support", "Shorter holds"],
    progressions: ["Ring support scap shrugs", "Ring support hold"],
    youtubeQuery: "ring support hold assisted proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_support_scap_shrugs",
    primaryMuscles: ["Lower traps", "Serratus"],
    secondaryMuscles: ["Triceps (lockout)", "Core"],
    setup:
        "In ring support (assisted if needed). Elbows locked the whole time.",
    execution:
        "Depress and slightly elevate scapula with small range while keeping rings steady.",
    cues: [
      "Elbows locked",
      "Small range",
      "Rings quiet",
      "Shoulders move, not elbows",
    ],
    commonMistakes: [
      "Bending elbows",
      "Big uncontrolled reps",
      "Rings shaking wildly",
    ],
    regressions: ["Assisted ring support hold"],
    progressions: ["Ring support hold", "RTO support"],
    youtubeQuery: "ring support scapular shrugs proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_support_hold",
    primaryMuscles: ["Triceps (lockout)", "Shoulders (stability)"],
    secondaryMuscles: ["Core", "Chest"],
    setup:
        "Rings at sides. Elbows locked. Body hollow. Turn rings slightly out if comfortable.",
    execution:
        "Hold stable without shaking. Keep rings close and shoulders down.",
    cues: ["Lock elbows", "Shoulders down", "Rings close", "Hollow body"],
    commonMistakes: [
      "Bent elbows",
      "Rings drifting",
      "Shrugging",
      "Arching ribs",
    ],
    regressions: ["Ring support assisted"],
    progressions: ["Ring dip negative", "RTO support"],
    youtubeQuery: "strict ring support hold form",
  ),
  SeedMovementGuide(
    movementId: "ring_row",
    primaryMuscles: ["Mid-back", "Lats"],
    secondaryMuscles: ["Biceps", "Rear delts", "Core"],
    setup: "Rings at hip height. Body straight. Heels down.",
    execution: "Row chest to rings, pause, lower slow. Keep shoulders packed.",
    cues: [
      "Squeeze shoulder blades",
      "Body rigid",
      "Chest to rings",
      "Control down",
    ],
    commonMistakes: [
      "Hips sagging",
      "Shrugging",
      "Half reps",
      "Rings flaring wide",
    ],
    regressions: ["More upright angle"],
    progressions: ["False grip ring row", "Ring pull-up"],
    youtubeQuery: "ring row proper form bodyweight row",
  ),
  SeedMovementGuide(
    movementId: "ring_face_pull",
    primaryMuscles: ["Rear delts", "Upper back"],
    secondaryMuscles: ["Rotator cuff", "Biceps"],
    setup: "Row setup but aim higher. Keep elbows high and out.",
    execution:
        "Pull rings toward face/forehead with scap retraction/external rotation control.",
    cues: ["Elbows high", "Squeeze upper back", "Control down", "No shrug"],
    commonMistakes: [
      "Elbows dropping",
      "Using momentum",
      "Shrugging shoulders",
    ],
    regressions: ["Ring row"],
    progressions: ["Harder angle", "Tempo reps"],
    youtubeQuery: "ring face pull proper form rear delt scap",
  ),
  SeedMovementGuide(
    movementId: "ring_push_up",
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front delts", "Core", "Serratus"],
    setup: "Rings set low. Hands in rings, rings close to ribs. Body rigid.",
    execution:
        "Lower with control keeping rings close. Press to lockout without rings drifting.",
    cues: ["Rings close", "Body in one line", "Full range", "Lockout"],
    commonMistakes: [
      "Rings flaring wide",
      "Hips sagging",
      "Half reps",
      "Shoulders shrugged",
    ],
    regressions: ["Higher rings", "Incline push-up"],
    progressions: ["Ring dip negative", "Ring dip"],
    youtubeQuery: "ring push up strict form rings close",
  ),
  SeedMovementGuide(
    movementId: "ring_pull_up",
    primaryMuscles: ["Lats"],
    secondaryMuscles: ["Biceps", "Mid-back", "Forearms"],
    setup: "Rings overhead. Start active hang. Keep rings close and neutral.",
    execution:
        "Pull chest up to rings, pause, lower to full hang with control.",
    cues: ["Shoulders down", "Rings close", "No swing", "Full range"],
    commonMistakes: [
      "Swinging",
      "Shrugging",
      "Half reps",
      "Rings drifting out",
    ],
    regressions: ["Pull-up", "Ring row"],
    progressions: ["False grip hang", "Ring muscle-up transition"],
    youtubeQuery: "ring pull up strict form",
  ),
  SeedMovementGuide(
    movementId: "false_grip_hang",
    primaryMuscles: ["Forearms (false grip)"],
    secondaryMuscles: ["Biceps", "Lats (stability)"],
    setup:
        "Wrists over rings (false grip). Start supported if needed to reduce load.",
    execution:
        "Hold with shoulders packed and rings close. Keep wrists in position.",
    cues: ["Wrists over rings", "Shoulders down", "Rings close", "Breathe"],
    commonMistakes: [
      "Letting grip slip to normal",
      "Shrugging",
      "Overdoing volume too fast",
    ],
    regressions: ["Partial false grip", "Feet-assisted hang"],
    progressions: ["False grip ring row", "Ring muscle-up transition"],
    youtubeQuery: "false grip hang rings how to",
  ),
  SeedMovementGuide(
    movementId: "false_grip_row",
    primaryMuscles: ["Lats", "Biceps"],
    secondaryMuscles: ["Forearms", "Mid-back"],
    setup: "Ring row position but maintain false grip throughout.",
    execution:
        "Row chest to rings, pause, lower slow while keeping false grip.",
    cues: [
      "Keep false grip",
      "Shoulders down",
      "Chest to rings",
      "Control down",
    ],
    commonMistakes: [
      "Losing false grip mid-rep",
      "Shrugging",
      "Using momentum",
    ],
    regressions: ["Ring row", "Shorter range"],
    progressions: ["Ring transition low", "Ring muscle-up"],
    youtubeQuery: "false grip ring row proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_l_sit_support",
    primaryMuscles: ["Hip flexors", "Abs (compression)"],
    secondaryMuscles: ["Shoulders (stability)", "Triceps", "Forearms"],
    setup: "Strong ring support first. Rings close, elbows locked.",
    execution:
        "Lift straight legs to L position and hold while keeping rings steady.",
    cues: ["Lock elbows", "Shoulders down", "Rings quiet", "Legs straight"],
    commonMistakes: [
      "Rings shaking wide",
      "Bent elbows",
      "Legs dropping",
      "Shrugging",
    ],
    regressions: ["L-sit on parallettes", "Tuck L-sit on rings"],
    progressions: ["Longer holds", "RTO work"],
    youtubeQuery: "ring l sit support hold proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_support_turnout_assisted",
    primaryMuscles: ["Triceps", "Shoulders (stability)"],
    secondaryMuscles: ["Chest", "Core"],
    setup: "Assisted ring support (feet/band). Turn rings out slightly at top.",
    execution: "Hold turnout position with elbows locked and shoulders down.",
    cues: ["Turn rings out", "Lock elbows", "Stay tall", "Rings close"],
    commonMistakes: ["Losing turnout", "Bent elbows", "Shrugging"],
    regressions: ["Ring support assisted"],
    progressions: ["Ring support RTO hold"],
    youtubeQuery: "rings turned out support assisted form",
  ),
  SeedMovementGuide(
    movementId: "ring_support_rto",
    primaryMuscles: ["Triceps", "Shoulders (stability)"],
    secondaryMuscles: ["Chest", "Core"],
    setup: "Strict ring support. Turn rings out 15-45 degrees at lockout.",
    execution: "Hold steady turnout with elbows locked and rings close.",
    cues: ["Lock elbows", "Rings turned out", "Shoulders down", "Body hollow"],
    commonMistakes: [
      "Losing turnout",
      "Bent elbows",
      "Rings drifting",
      "Rib flare",
    ],
    regressions: ["Assisted RTO support"],
    progressions: ["Ring dip (RTO finish)", "Cross lean prep"],
    youtubeQuery: "ring support rto hold strict form",
  ),
  SeedMovementGuide(
    movementId: "ring_dip_negative",
    primaryMuscles: ["Triceps", "Chest"],
    secondaryMuscles: ["Shoulders", "Core"],
    setup: "Start at top ring support. Rings close, elbows locked.",
    execution:
        "Lower slowly to deep dip (pain-free) keeping rings close. Step out to reset.",
    cues: ["Slow down", "Rings close", "Elbows track", "Shoulders controlled"],
    commonMistakes: [
      "Rings flaring wide",
      "Dropping fast",
      "Shoulders collapsing",
    ],
    regressions: ["Ring support hold", "Parallel dip negatives"],
    progressions: ["Ring dip"],
    youtubeQuery: "ring dip negative proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_dip",
    primaryMuscles: ["Triceps", "Chest"],
    secondaryMuscles: ["Shoulders", "Core"],
    setup: "Stable ring support first. Keep rings close to body.",
    execution:
        "Lower under control, then press to full lockout without rings drifting.",
    cues: ["Rings close", "Full lockout", "Control bottom", "No shrug"],
    commonMistakes: [
      "Rings flaring",
      "Half reps",
      "Shoulders rolling forward",
      "Bouncing",
    ],
    regressions: ["Ring dip negatives", "Parallel bar dips"],
    progressions: ["Ring dip RTO finish", "Ring muscle-up"],
    youtubeQuery: "ring dip strict form tutorial",
  ),
  SeedMovementGuide(
    movementId: "ring_turnout_dip",
    primaryMuscles: ["Triceps", "Chest"],
    secondaryMuscles: ["Shoulders (stability)", "Core"],
    setup: "Ring dip baseline. Aim to turn rings out at the top lockout.",
    execution:
        "Perform dip, then finish at top with rings turned out and elbows locked.",
    cues: ["Turnout at top", "Lock elbows", "Rings close", "Stay tall"],
    commonMistakes: [
      "Forcing turnout mid-rep",
      "Bent elbows at top",
      "Rings drifting wide",
    ],
    regressions: ["Ring dip", "RTO support"],
    progressions: ["Ring transition low", "Ring muscle-up"],
    youtubeQuery: "ring dip rings turned out finish form",
  ),
  SeedMovementGuide(
    movementId: "ring_transition_low",
    primaryMuscles: ["Lats", "Triceps"],
    secondaryMuscles: ["Chest", "Forearms (false grip)", "Shoulders"],
    setup:
        "Low rings. Use false grip. Start from kneeling/feet-supported to reduce load.",
    execution:
        "Pull rings to chest, then rotate elbows over and press to support smoothly.",
    cues: ["False grip", "Rings tight", "Fast elbows over", "Stay close"],
    commonMistakes: [
      "Letting rings drift",
      "Losing false grip",
      "Chicken wing",
      "Too much swinging",
    ],
    regressions: ["False grip row", "Ring dip (RTO finish)"],
    progressions: ["Ring muscle-up"],
    youtubeQuery: "ring muscle up transition low rings false grip drill",
  ),
  SeedMovementGuide(
    movementId: "ring_muscle_up",
    primaryMuscles: ["Lats", "Chest", "Triceps"],
    secondaryMuscles: ["Forearms (false grip)", "Shoulders", "Core"],
    setup:
        "False grip solid. Strong ring pull-up + ring dip baseline. Start controlled.",
    execution:
        "Pull high, transition elbows over, press to support. Keep rings close throughout.",
    cues: ["Rings close", "False grip", "Fast turnover", "Strong lockout"],
    commonMistakes: [
      "No false grip",
      "Rings flaring",
      "Chicken wing",
      "Low pull",
    ],
    regressions: ["Ring transition low", "Band-assisted ring muscle-up"],
    progressions: ["Cleaner strict reps", "Paused transitions"],
    youtubeQuery: "strict ring muscle up false grip technique",
  ),
  SeedMovementGuide(
    movementId: "ring_inverted_hang",
    primaryMuscles: ["Shoulders (stability)"],
    secondaryMuscles: ["Core", "Upper back", "Forearms"],
    setup:
        "Get inverted via skin-the-cat. Keep rings close and shoulders active.",
    execution:
        "Hold upside down with straight body line and controlled breathing.",
    cues: ["Rings close", "Shoulders active", "Stay stacked", "Breathe"],
    commonMistakes: ["Rings drifting", "Loose body", "Neck cranking"],
    regressions: ["Skin the cat"],
    progressions: ["Ring tuck back lever", "Ring back lever"],
    youtubeQuery: "ring inverted hang hold proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_tuck_back_lever",
    primaryMuscles: ["Shoulders (extension strength)"],
    secondaryMuscles: ["Abs", "Glutes", "Upper back"],
    setup: "From ring inverted hang. Tuck knees and set shoulders active.",
    execution:
        "Lower into tuck back lever and hold with glutes engaged and no pike.",
    cues: ["Active shoulders", "Glutes on", "No pike", "Rings close"],
    commonMistakes: ["Piking", "Shoulders collapsing", "Rings drifting"],
    regressions: ["Ring inverted hang", "Skin the cat"],
    progressions: ["Ring back lever"],
    youtubeQuery: "ring tuck back lever hold proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_back_lever",
    primaryMuscles: ["Shoulders (extension strength)"],
    secondaryMuscles: ["Abs", "Glutes", "Upper back"],
    setup: "Strong tuck back lever first. Rings stable and close.",
    execution:
        "Hold full back lever on rings with straight body and active shoulders.",
    cues: ["Glutes tight", "Ribs down", "Rings close", "Active shoulders"],
    commonMistakes: [
      "Rings drifting wide",
      "Piking",
      "Bent arms",
      "Loose core",
    ],
    regressions: ["Ring tuck back lever"],
    progressions: ["Cross lean (prep)"],
    youtubeQuery: "ring back lever strict form",
  ),
  SeedMovementGuide(
    movementId: "ring_cross_lean",
    primaryMuscles: ["Chest", "Biceps tendon tolerance"],
    secondaryMuscles: ["Shoulders", "Forearms", "Core"],
    setup:
        "From RTO support. Slowly lean arms wider with minimal bend. Use assistance if needed.",
    execution:
        "Hold a controlled lean toward cross angle without pain. Keep shoulders packed.",
    cues: [
      "Go slow",
      "Shoulders packed",
      "Minimal elbow bend",
      "Pain-free only",
    ],
    commonMistakes: [
      "Forcing range",
      "Dropping suddenly",
      "Painful shoulders/elbows",
    ],
    regressions: ["RTO support", "Band-assisted lean"],
    progressions: ["Assisted iron cross"],
    youtubeQuery: "ring cross lean tendon prep proper form",
  ),
  SeedMovementGuide(
    movementId: "ring_assisted_iron_cross",
    primaryMuscles: ["Chest", "Shoulders"],
    secondaryMuscles: ["Biceps tendon tolerance", "Forearms", "Core"],
    setup:
        "Use bands. Start in stable support and lower into assisted cross position.",
    execution:
        "Hold assisted cross with straight arms and shoulders packed. Exit carefully.",
    cues: ["Bands help", "Shoulders packed", "Straight arms", "Short holds"],
    commonMistakes: [
      "Too much load too soon",
      "Pain in elbow/shoulder",
      "Dropping fast",
    ],
    regressions: ["Cross lean", "More band assistance"],
    progressions: ["Iron cross"],
    youtubeQuery: "assisted iron cross rings bands proper form",
  ),
  SeedMovementGuide(
    movementId: "iron_cross",
    primaryMuscles: ["Chest", "Shoulders"],
    secondaryMuscles: ["Biceps tendon tolerance", "Forearms", "Core"],
    setup:
        "Extremely advanced. Warm up thoroughly. Build through assisted work first.",
    execution:
        "Hold cross with straight arms and packed shoulders. Keep body quiet and controlled.",
    cues: ["Packed shoulders", "Straight arms", "Short holds", "Control exit"],
    commonMistakes: [
      "Forcing without prep",
      "Pain/tendon flare-ups",
      "Shrugging",
    ],
    regressions: ["Assisted iron cross", "Cross lean"],
    progressions: ["Longer holds", "Cleaner entries"],
    youtubeQuery: "iron cross rings strict hold technique",
  ),
  SeedMovementGuide(
    movementId: "assisted_maltese",
    primaryMuscles: ["Shoulders (straight-arm strength)"],
    secondaryMuscles: ["Chest", "Biceps tendon tolerance", "Core"],
    setup: "Use strong bands. Body closer to horizontal support position.",
    execution:
        "Hold assisted maltese with straight arms and protracted/packed shoulders.",
    cues: ["Straight arms", "Go slow", "Short holds", "Pain-free only"],
    commonMistakes: ["Too much load", "Elbow pain", "Dropping fast"],
    regressions: ["Assisted iron cross", "Planche lean"],
    progressions: ["Maltese"],
    youtubeQuery: "assisted maltese rings bands proper form",
  ),
  SeedMovementGuide(
    movementId: "maltese",
    primaryMuscles: ["Shoulders (straight-arm strength)"],
    secondaryMuscles: ["Chest", "Biceps tendon tolerance", "Core"],
    setup: "Elite level. Only after long assisted progression.",
    execution:
        "Hold maltese position with straight arms and locked body tension.",
    cues: [
      "Straight arms",
      "Packed shoulders",
      "Full body tension",
      "Control exit",
    ],
    commonMistakes: [
      "Rushing progression",
      "Elbow/shoulder pain",
      "Losing tension",
    ],
    regressions: ["Assisted maltese"],
    progressions: ["Longer holds"],
    youtubeQuery: "rings maltese hold strict technique",
  ),

  SeedMovementGuide(
    movementId: "ring_biceps_curl",
    primaryMuscles: ["Biceps"],
    secondaryMuscles: ["Forearms", "Upper back (stability)"],
    setup: "Rings low. Lean back. Keep elbows high and fixed.",
    execution:
        "Curl rings to forehead/face with control. Lower slow without losing elbow position.",
    cues: [
      "Elbows stay up",
      "Control eccentric",
      "No swinging",
      "Squeeze biceps",
    ],
    commonMistakes: ["Elbows dropping", "Using momentum", "Shoulders shrugged"],
    regressions: ["More upright angle"],
    progressions: ["Harder lean", "Slower tempo"],
    youtubeQuery: "ring biceps curl proper form elbows high",
  ),
  SeedMovementGuide(
    movementId: "ring_triceps_extension",
    primaryMuscles: ["Triceps"],
    secondaryMuscles: ["Shoulders", "Core"],
    setup: "Rings low. Body leaned forward. Elbows tucked.",
    execution:
        "Bend elbows to bring head/hands forward, then extend elbows to lockout.",
    cues: ["Elbows in", "Body rigid", "Full lockout", "Slow down"],
    commonMistakes: [
      "Elbows flaring",
      "Arching ribs",
      "Half reps",
      "Using momentum",
    ],
    regressions: ["More upright angle"],
    progressions: ["Harder lean", "Ring dip work"],
    youtubeQuery: "ring triceps extension strict form",
  ),
  SeedMovementGuide(
    movementId: "ring_fly",
    primaryMuscles: ["Chest"],
    secondaryMuscles: ["Front delts", "Biceps tendon tolerance", "Core"],
    setup:
        "Assisted angle (more upright). Rings slightly forward of shoulders. Shoulders packed.",
    execution:
        "Open arms slowly to a pain-free stretch, then bring rings back together with control.",
    cues: [
      "Shoulders packed",
      "Slow range",
      "No deep painful stretch",
      "Control return",
    ],
    commonMistakes: [
      "Overstretching",
      "Shoulders rolling forward",
      "Dropping too fast",
    ],
    regressions: ["More upright", "Smaller range"],
    progressions: ["Harder lean", "Slower tempo"],
    youtubeQuery: "ring fly assisted proper form shoulder safe",
  ),
  SeedMovementGuide(
    movementId: "ring_support_swings",
    primaryMuscles: ["Shoulders (stability)"],
    secondaryMuscles: ["Core", "Triceps"],
    setup: "Assisted ring support if needed. Rings close, elbows locked.",
    execution:
        "Small controlled forward/back swings while maintaining lockout and stability.",
    cues: ["Small swings", "Elbows locked", "Shoulders down", "Rings close"],
    commonMistakes: ["Big uncontrolled swings", "Bent elbows", "Shrugging"],
    regressions: ["Ring support assisted hold"],
    progressions: ["Ring support hold", "RTO support"],
    youtubeQuery: "ring support swings control stability drill",
  ),
  SeedMovementGuide(
    movementId: "ring_external_rotation",
    primaryMuscles: ["Rotator cuff (external rotators)"],
    secondaryMuscles: ["Rear delts", "Mid-back"],
    setup:
        "Light resistance. Elbows near sides or supported. Pain-free range only.",
    execution:
        "Rotate outward slowly, pause, return under control. Keep shoulder down.",
    cues: ["Slow reps", "No pain", "Shoulder down", "Control both ways"],
    commonMistakes: ["Too heavy", "Shrugging", "Rushing", "Painful range"],
    regressions: ["Band external rotations lighter"],
    progressions: ["More control/tempo", "Face pulls"],
    youtubeQuery:
        "external rotation shoulder exercise proper form rotator cuff",
  ),
];

final Map<String, SeedMovementGuide> seedMovementGuidesById = Map.unmodifiable({
  for (final g in seedMovementGuides) g.movementId: g,
});
