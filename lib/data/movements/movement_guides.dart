class MovementGuide
{
  const MovementGuide({
    required this.summary,
    required this.targets,
    required this.formCues,
    this.mistakes,
  });

  /// Short, card-friendly description
  final String summary;

  /// Use " • " separators (easy to render as chips)
  final String targets;

  /// Use " • " separators (easy to render as bullets)
  final String formCues;

  /// Optional, use " • " separators
  final String? mistakes;

  List<String> get targetsList => targets.split(" • ").where((x) => x.trim().isNotEmpty).toList();
  List<String> get cuesList => formCues.split(" • ").where((x) => x.trim().isNotEmpty).toList();
  List<String> get mistakesList =>
      (mistakes == null || mistakes!.trim().isEmpty) ? const [] : mistakes!.split(" • ").where((x) => x.trim().isNotEmpty).toList();
}

const Map<String, MovementGuide> movementGuides =
{
  // =========================
  // MOBILITY / PREHAB
  // =========================
  "wrist_mobility": MovementGuide(
    summary: "Prep wrists for load-bearing (handstands/planche) with slow circles, pulses, and gentle leans.",
    targets: "Wrists • Forearms • Connective tissue",
    formCues: "Move slow • Stay pain-free • Keep elbows straight on leans",
  ),
  "shoulder_dislocates": MovementGuide(
    summary: "Open overhead range and keep shoulders healthy using a band/broom through a smooth arc.",
    targets: "Shoulders • Upper back • Thoracic mobility",
    formCues: "Straight arms • Ribcage down • Smooth tempo, no forcing",
  ),
  "thoracic_extension": MovementGuide(
    summary: "Improve upper-back extension to make overhead, bridge, and handstand shapes easier.",
    targets: "Thoracic spine • Upper back • Lats",
    formCues: "Breathe into upper ribs • Extend through mid-back • Don’t crank low back",
  ),
  "hamstring_mobility": MovementGuide(
    summary: "Pike-focused hamstring work to build compression and reduce stiffness over time.",
    targets: "Hamstrings • Calves • Posterior chain",
    formCues: "Long spine • Hinge at hips • Easy breathing, no bouncing",
  ),
  "pancake_stretch": MovementGuide(
    summary: "Straddle flexibility for V-sit/press work—build range gradually with controlled holds.",
    targets: "Adductors • Hamstrings • Hip capsule",
    formCues: "Hinge forward • Neutral spine • Gentle pressure, breathe",
  ),
  "bridge_prep": MovementGuide(
    summary: "Prep shoulders + thoracic spine for bridging using wall opens and controlled extensions.",
    targets: "Shoulders • Thoracic spine • Hip flexors",
    formCues: "Ribs controlled • Open shoulders first • Progress slowly",
  ),
  "bridge": MovementGuide(
    summary: "Full bridge hold—push tall, breathe, and keep weight balanced through hands and feet.",
    targets: "Spine extensors • Shoulders • Glutes",
    formCues: "Arms straight if possible • Push chest through • Don’t dump into low back",
    mistakes: "Painful pinching • Collapsing elbows • Holding breath",
  ),

  // =========================
  // CORE / FOUNDATION
  // =========================
  "plank": MovementGuide(
    summary: "Total-body brace—build a solid line from shoulders to heels.",
    targets: "Deep core • Glutes • Serratus",
    formCues: "Ribs down • Squeeze glutes • Push floor away",
  ),
  "side_plank": MovementGuide(
    summary: "Oblique + shoulder stability—stack hips and own the line.",
    targets: "Obliques • Glute med • Shoulder stabilizers",
    formCues: "Hips stacked • Long neck • Don’t sag at the waist",
  ),
  "hollow_hold": MovementGuide(
    summary: "Gymnastic core staple—posterior tilt with low back glued to the floor.",
    targets: "Abs • Hip flexors • Serratus",
    formCues: "Low back down • Ribs tucked • Reach long",
  ),
  "arch_hold": MovementGuide(
    summary: "Posterior chain tension for levers and pulling—keep glutes on.",
    targets: "Spinal erectors • Glutes • Upper back",
    formCues: "Squeeze glutes • Long body • Lift from upper back, not neck",
  ),
  "hanging_knee_raise": MovementGuide(
    summary: "Controlled knee-to-chest raises—build abs and reduce swing.",
    targets: "Abs • Hip flexors • Grip",
    formCues: "Active hang • Exhale up • No swinging",
  ),
  "hanging_leg_raise": MovementGuide(
    summary: "Straight-leg raises with control—big compression strength builder.",
    targets: "Lower abs • Hip flexors • Lats (stability)",
    formCues: "Posterior tilt at top • Slow down • Keep legs straight",
  ),
  "toes_to_bar": MovementGuide(
    summary: "High-core strength move—aim for strict reps before adding speed.",
    targets: "Abs • Hip flexors • Grip",
    formCues: "Active hang • Controlled raise • Touch softly, lower slow",
  ),
  "tuck_l_sit": MovementGuide(
    summary: "Support + compression—press down through shoulders and lift knees tight.",
    targets: "Abs • Hip flexors • Triceps (support)",
    formCues: "Locked elbows • Shoulders depressed • Knees high, chest proud",
  ),
  "l_sit": MovementGuide(
    summary: "Full L-sit—straight legs, active shoulders, and hard compression.",
    targets: "Abs • Hip flexors • Quads • Triceps (support)",
    formCues: "Lock elbows • Push tall • Point toes, don’t slump",
  ),
  "v_sit": MovementGuide(
    summary: "Compression + flexibility milestone—lift taller and close the hip angle.",
    targets: "Abs • Hip flexors • Adductors • Quads",
    formCues: "Push tall • Lift legs via compression • Don’t collapse shoulders",
  ),
  "hanging_oblique_raise": MovementGuide(
    summary: "Side-to-side knee/leg raises—train obliques with control.",
    targets: "Obliques • Abs • Hip flexors",
    formCues: "Minimal swing • Rotate from torso • Slow return",
  ),
  "hanging_windshield_wiper": MovementGuide(
    summary: "Advanced oblique control—smooth arcs side-to-side without momentum.",
    targets: "Obliques • Abs • Lats (stability)",
    formCues: "Brace hard • Small swing • Smooth arc, slow transitions",
  ),
  "tuck_dragon_flag": MovementGuide(
    summary: "Dragon flag entry—tucked lever with hips locked and slow lowering.",
    targets: "Abs • Lats • Hip flexors",
    formCues: "Hips locked • Lower slow • Don’t fold at the waist",
  ),
  "dragon_flag_negative": MovementGuide(
    summary: "Start high and lower under control—keep a straight line through hips.",
    targets: "Abs • Lats • Serratus",
    formCues: "Straight line • Slow eccentric • Brace and breathe",
  ),
  "dragon_flag": MovementGuide(
    summary: "Full dragon flag reps—max tension through core and upper body.",
    targets: "Abs • Lats • Serratus",
    formCues: "No hip bend • Controlled reps • Own the eccentric",
  ),
  "pike_compression": MovementGuide(
    summary: "Seated pike lifts—build press-handstand compression strength.",
    targets: "Hip flexors • Abs • Quads",
    formCues: "Tall spine • Lift heels cleanly • No rocking",
  ),
  "seated_pike_lift": MovementGuide(
    summary: "Hands by hips—lift both legs with strong shoulder depression.",
    targets: "Hip flexors • Abs • Triceps (support)",
    formCues: "Press down hard • Legs together • Smooth lift + lower",
  ),
  "straddle_compression": MovementGuide(
    summary: "Straddle leg lifts—big carryover to straddle press and V-sit.",
    targets: "Hip flexors • Abs • Adductors",
    formCues: "Tall posture • Lift evenly • Control the lowering",
  ),

  // =========================
  // PUSH
  // =========================
  "incline_push_up": MovementGuide(
    summary: "Elevated hands to learn clean push-up mechanics and full range.",
    targets: "Chest • Triceps • Front delts • Core",
    formCues: "Straight line • Elbows ~30–45° • Full lockout",
  ),
  "knee_push_up": MovementGuide(
    summary: "Regress push-ups while keeping torso braced and range consistent.",
    targets: "Chest • Triceps • Front delts",
    formCues: "Hips forward (no pike) • Chest to target • Lock out fully",
  ),
  "push_up": MovementGuide(
    summary: "Classic horizontal press—strong line, full range, smooth reps.",
    targets: "Chest • Triceps • Front delts • Serratus",
    formCues: "Brace ribs down • Chest touches • Push floor away at top",
  ),
  "diamond_push_up": MovementGuide(
    summary: "Triceps-biased push-up—keep elbows tucked and reps controlled.",
    targets: "Triceps • Chest (inner) • Front delts",
    formCues: "Hands under sternum • Elbows close • Don’t flare shoulders",
  ),
  "decline_push_up": MovementGuide(
    summary: "Feet elevated to load shoulders—great step toward HSPU strength.",
    targets: "Shoulders • Upper chest • Triceps",
    formCues: "Hips level • Head slightly forward • Control bottom position",
  ),
  "archer_push_up": MovementGuide(
    summary: "Unilateral shift—one arm works while the other assists.",
    targets: "Chest • Triceps • Shoulders • Core",
    formCues: "Shift smoothly • Working elbow tracks • Keep hips square",
  ),
  "pseudo_planche_push_up": MovementGuide(
    summary: "Planche-lean push-ups—straight-arm strength + forward shoulder load.",
    targets: "Front delts • Chest • Triceps • Serratus • Wrists",
    formCues: "Lean forward • Protract scapula • Keep elbows close and controlled",
  ),
  "support_hold": MovementGuide(
    summary: "Locked-out support on bars/rings—build shoulder stability and control.",
    targets: "Triceps • Lower traps • Serratus • Core",
    formCues: "Elbows locked • Shoulders down • Hollow body, no shrug",
  ),
  "parallel_dip": MovementGuide(
    summary: "Strict dips with shoulder control—own depth and lockout.",
    targets: "Triceps • Chest • Front delts",
    formCues: "Shoulders packed • Elbows track back • Full lockout at top",
  ),
  "pike_push_up": MovementGuide(
    summary: "Shoulder-focused press—vertical pattern without handstand.",
    targets: "Shoulders • Triceps • Upper chest",
    formCues: "Hips high • Head to floor in front • Control the descent",
  ),
  "elevated_pike_push_up": MovementGuide(
    summary: "More vertical pressing—big carryover to wall HSPU.",
    targets: "Shoulders • Triceps • Upper chest",
    formCues: "Feet elevated • Head forward • Keep elbows from flaring",
  ),

  // =========================
  // PULL
  // =========================
  "active_hang": MovementGuide(
    summary: "Hang with shoulders engaged—build scap control and healthier pulling.",
    targets: "Lats • Lower traps • Grip",
    formCues: "Scap down • Long neck • Still body, no swinging",
  ),
  "scap_pull_up": MovementGuide(
    summary: "Small-range scap pull—learn depression/retraction without bending arms.",
    targets: "Lower traps • Lats • Rhomboids",
    formCues: "Arms straight • Pull shoulders down • Pause at top",
  ),
  "australian_pull_up": MovementGuide(
    summary: "Body rows for pull-up strength—keep body rigid and pull to ribs.",
    targets: "Mid-back • Lats • Biceps",
    formCues: "Hollow body • Pull chest to bar • Squeeze shoulder blades",
  ),
  "negative_pull_up": MovementGuide(
    summary: "Jump to top and lower slowly—build strict pull-up strength fast.",
    targets: "Lats • Biceps • Mid-back",
    formCues: "Start chin over bar • 3–6s lower • No shoulder shrug",
  ),
  "chin_up": MovementGuide(
    summary: "Strict chin-ups—full range with no swing.",
    targets: "Biceps • Lats • Mid-back",
    formCues: "Dead hang start • Chest up • Control the descent",
  ),
  "pull_up": MovementGuide(
    summary: "Strict pull-ups—powerful lats with clean reps and full control.",
    targets: "Lats • Mid-back • Biceps • Grip",
    formCues: "Active hang • Pull elbows down • No kipping",
  ),
  "explosive_pull_up": MovementGuide(
    summary: "Pull high and fast—bridge to muscle-up power.",
    targets: "Lats • Biceps • Upper back",
    formCues: "Tight body • Pull to lower chest • Control down",
  ),
  "archer_pull_up": MovementGuide(
    summary: "Unilateral bias—pull more to one side while the other assists.",
    targets: "Lats • Biceps • Scap stabilizers",
    formCues: "Pull to one hand • Keep shoulders square • Slow transitions",
  ),
  "typewriter_pull_up": MovementGuide(
    summary: "Hold high and move side-to-side—serious strength and control.",
    targets: "Lats • Biceps • Upper back • Core",
    formCues: "Stay high • Move smoothly • Don’t drop between sides",
  ),
  "uneven_pull_up": MovementGuide(
    summary: "One hand lower to safely bias one arm—great stepping stone.",
    targets: "Lats • Biceps • Grip",
    formCues: "Lower hand assists lightly • No twisting • Control down",
  ),
  "one_arm_hang": MovementGuide(
    summary: "One-arm hang—build grip and shoulder tolerance with packed scapula.",
    targets: "Grip • Forearms • Lats • Rotator cuff",
    formCues: "Shoulder packed • Slight bend okay • Short holds, quality only",
    mistakes: "Painful shoulder stretch • Shrugging • Overdoing volume",
  ),
  "one_arm_lockoff": MovementGuide(
    summary: "Hold at top/mid—huge unilateral pulling milestone.",
    targets: "Lats • Biceps • Upper back • Grip",
    formCues: "Stable shoulder • No swinging • Build time gradually",
  ),
  "one_arm_negative_pull_up": MovementGuide(
    summary: "Start high and lower slowly on one arm—very demanding on tendons.",
    targets: "Lats • Biceps • Forearms",
    formCues: "Controlled eccentric • Shoulder packed • Stop before form breaks",
    mistakes: "Dropping fast • Shoulder shrug • Elbow pain ignoring",
  ),
  "one_arm_pull_up": MovementGuide(
    summary: "Full one-arm pull-up—elite strength. Progress patiently.",
    targets: "Lats • Biceps • Forearms • Core",
    formCues: "No swing • Smooth pull • Controlled eccentric",
  ),

  // =========================
  // LEGS
  // =========================
  "bodyweight_squat": MovementGuide(
    summary: "Foundational squat—depth, balance, and knee tracking.",
    targets: "Quads • Glutes • Adductors",
    formCues: "Knees track toes • Full foot pressure • Control depth",
  ),
  "split_squat": MovementGuide(
    summary: "Single-leg strength and balance builder—great for knee resilience.",
    targets: "Quads • Glutes • Adductors",
    formCues: "Tall torso • Front knee tracks toes • Drive through mid-foot",
  ),
  "bulgarian_split_squat": MovementGuide(
    summary: "Rear-foot elevated—big quad + glute stimulus with control.",
    targets: "Quads • Glutes • Hamstrings",
    formCues: "Soft back knee • Front shin comfortable • Slow eccentric",
  ),
  "shrimp_squat": MovementGuide(
    summary: "Pistol prep—control balance and knee position through depth.",
    targets: "Quads • Glutes • Calves",
    formCues: "Knee tracks toes • Hips square • Tap knee softly, stand tall",
  ),
  "assisted_pistol_squat": MovementGuide(
    summary: "Use support to own depth and balance—keep it smooth and strict.",
    targets: "Quads • Glutes • Calves • Core",
    formCues: "Hold support lightly • Sit between heel and hip • Stand without bouncing",
  ),
  "pistol_squat": MovementGuide(
    summary: "Full single-leg squat—strength + mobility + control.",
    targets: "Quads • Glutes • Calves • Core",
    formCues: "Full foot pressure • Knee tracks toes • Control the bottom",
  ),

  // =========================
  // SKILLS
  // =========================
  "wall_handstand": MovementGuide(
    summary: "Chest-to-wall line drill—stack shoulders and build calm holds.",
    targets: "Shoulders • Triceps • Serratus • Wrists • Core",
    formCues: "Hands shoulder-width • Ribs down • Push tall through shoulders",
  ),
  "freestanding_handstand": MovementGuide(
    summary: "Balance without the wall—train shape first, then time.",
    targets: "Shoulders • Triceps • Serratus • Core",
    formCues: "Tight line • Small finger pressure • Stay tall, don’t pike",
  ),
  "wall_hspu_negative": MovementGuide(
    summary: "Controlled lowering for strict HSPU strength.",
    targets: "Shoulders • Triceps • Upper chest",
    formCues: "Head forward slightly • Slow descent • Keep ribs tucked",
  ),
  "wall_hspu": MovementGuide(
    summary: "Strict wall HSPU—full range without kipping.",
    targets: "Shoulders • Triceps • Upper chest",
    formCues: "Controlled bottom • Drive straight • Lockout strong",
  ),
  "tuck_press_handstand": MovementGuide(
    summary: "Press from tuck—shoulders forward + strong compression.",
    targets: "Shoulders • Upper traps • Abs • Hip flexors",
    formCues: "Lean shoulders forward • Compress hard • Slow, smooth press",
  ),
  "straddle_press_handstand": MovementGuide(
    summary: "Straddle press—flexibility + strength in one skill.",
    targets: "Shoulders • Abs • Hip flexors • Adductors",
    formCues: "Wide straddle • Keep hips rising • Don’t jump into it",
  ),
  "press_handstand": MovementGuide(
    summary: "Full pike press—high-level control and compression strength.",
    targets: "Shoulders • Abs • Hip flexors",
    formCues: "Shoulders forward • Slow lift • Keep legs straight",
  ),
  "tuck_front_lever": MovementGuide(
    summary: "Tuck lever hold—depressed scap + hollow body.",
    targets: "Lats • Upper back • Abs • Glutes",
    formCues: "Scap down • Ribs tucked • Keep hips level",
  ),
  "adv_tuck_front_lever": MovementGuide(
    summary: "Harder tuck—open hips while keeping scap depression.",
    targets: "Lats • Upper back • Abs",
    formCues: "Open hips slightly • Stay hollow • No swinging",
  ),
  "straddle_front_lever": MovementGuide(
    summary: "Straddle lever—reduce lever arm while keeping a flat torso.",
    targets: "Lats • Upper back • Abs • Glutes",
    formCues: "Scap depressed • Hips level • Don’t pike",
  ),
  "front_lever": MovementGuide(
    summary: "Full front lever hold—elite lat + core control.",
    targets: "Lats • Upper back • Abs • Glutes",
    formCues: "Scap down • Straight body • Still hang, no swing",
  ),
  "tuck_front_lever_raises": MovementGuide(
    summary: "Dynamic lever strength—control arc without momentum.",
    targets: "Lats • Upper back • Abs",
    formCues: "Start from active hang • Smooth raise • Slow lower",
  ),
  "adv_tuck_front_lever_raises": MovementGuide(
    summary: "Harder raises—keep ribs down and scap depressed.",
    targets: "Lats • Upper back • Abs",
    formCues: "No swinging • Pause at top • Control down",
  ),
  "front_lever_raises": MovementGuide(
    summary: "Full lever raises—elite dynamic strength.",
    targets: "Lats • Upper back • Abs • Grip",
    formCues: "Tight line • Smooth reps • Own the eccentric",
  ),
  "german_hang": MovementGuide(
    summary: "Shoulder extension under load—go slow and respect your range.",
    targets: "Shoulders (extension) • Biceps tendon • Chest",
    formCues: "Small range first • Controlled breathing • Exit safely",
    mistakes: "Forcing depth • Sharp pain • Skipping warm-up",
  ),
  "skin_the_cat": MovementGuide(
    summary: "Controlled rotation through German hang—build shoulder tolerance.",
    targets: "Shoulders • Lats • Core",
    formCues: "Move slow • Keep rings/bar close • Don’t drop into bottom",
  ),
  "tuck_back_lever": MovementGuide(
    summary: "Back lever entry—active shoulders and glutes on.",
    targets: "Shoulders • Chest • Lats • Core",
    formCues: "Shoulders packed • Glutes tight • No pike",
  ),
  "back_lever": MovementGuide(
    summary: "Full back lever hold—shoulder extension + body tension.",
    targets: "Shoulders • Chest • Lats • Core",
    formCues: "Active shoulders • Straight body • Controlled hold",
  ),
  "muscle_up_transition": MovementGuide(
    summary: "Turnover drill—stay close to the bar and learn the path.",
    targets: "Lats • Biceps • Triceps • Chest",
    formCues: "Keep bar close • Fast elbows over • Smooth to dip support",
  ),
  "bar_muscle_up": MovementGuide(
    summary: "Explosive pull + fast transition to dip—no ‘wild’ swing needed.",
    targets: "Lats • Biceps • Chest • Triceps",
    formCues: "Pull high • Keep close • Strong dip lockout",
  ),
  "flag_pole_support": MovementGuide(
    summary: "Flag base position—pack shoulders and keep hips tight.",
    targets: "Shoulders • Lats • Obliques • Grip",
    formCues: "Top arm pulls • Bottom arm pushes • Hips tight, no rotation",
  ),
  "tucked_human_flag": MovementGuide(
    summary: "Tucked flag hold—short lever for learning alignment and tension.",
    targets: "Obliques • Lats • Shoulders",
    formCues: "Shoulders packed • Knees tucked • No spinning",
  ),
  "adv_tuck_human_flag": MovementGuide(
    summary: "Harder tuck—more lever demand on core and shoulders.",
    targets: "Obliques • Lats • Shoulders",
    formCues: "Hips level • Push/pull arms • Tight brace",
  ),
  "straddle_human_flag": MovementGuide(
    summary: "Straddle flag—control hips and avoid rotation.",
    targets: "Obliques • Lats • Shoulders",
    formCues: "Legs straddle wide • Hips square • Smooth breathing",
  ),
  "human_flag": MovementGuide(
    summary: "Full human flag—elite shoulder + core strength.",
    targets: "Obliques • Lats • Shoulders • Grip",
    formCues: "Top arm pulls • Bottom arm pushes • Straight line, hips stacked",
  ),
  "planche_lean": MovementGuide(
    summary: "Straight-arm lean—teach planche protraction and forward shoulder load.",
    targets: "Front delts • Serratus • Wrists • Core",
    formCues: "Protract hard • Lean forward • Straight arms",
  ),
  "frog_stand": MovementGuide(
    summary: "Balance entry—elbow shelf and weight shift with control.",
    targets: "Shoulders • Triceps • Wrists • Core",
    formCues: "Lean forward • Eyes slightly ahead • Squeeze knees into arms",
  ),
  "tuck_planche": MovementGuide(
    summary: "Tucked planche hold—lock elbows and protract aggressively.",
    targets: "Front delts • Serratus • Triceps • Core",
    formCues: "Straight arms • Protract • Hollow body",
  ),
  "adv_tuck_planche": MovementGuide(
    summary: "Open hips while staying hollow—big straight-arm demand.",
    targets: "Front delts • Serratus • Triceps • Core",
    formCues: "Open hips slightly • Keep protraction • Don’t pike",
  ),
  "straddle_planche": MovementGuide(
    summary: "Straddle planche—reduce lever arm, keep shoulders forward.",
    targets: "Front delts • Serratus • Triceps • Core",
    formCues: "Wide straddle • Straight arms • Shoulder lean maintained",
  ),
  "planche": MovementGuide(
    summary: "Full planche—elite straight-arm pushing strength.",
    targets: "Front delts • Serratus • Triceps • Core • Wrists",
    formCues: "Straight arms • Protract • Hips level, tight line",
  ),

  // =========================
  // RINGS
  // =========================
  "ring_support_assisted": MovementGuide(
    summary: "Assisted ring support—learn stability with feet/band help.",
    targets: "Shoulders • Triceps • Core • Rotator cuff",
    formCues: "Lock elbows • Rings close • Shoulders down",
  ),
  "ring_support_scap_shrugs": MovementGuide(
    summary: "Small range scap control in support—build ring stability fast.",
    targets: "Lower traps • Serratus • Shoulders",
    formCues: "Elbows locked • Depress/elevate only • Rings stay quiet",
  ),
  "ring_support_hold": MovementGuide(
    summary: "Strict ring support—locked elbows, hollow body, still rings.",
    targets: "Shoulders • Triceps • Core • Rotator cuff",
    formCues: "Rings close • Shoulders down • No shaking by rushing",
  ),
  "ring_row": MovementGuide(
    summary: "Ring rows—pull to ribs while keeping body rigid.",
    targets: "Mid-back • Lats • Biceps",
    formCues: "Hollow body • Pull elbows back • Pause and squeeze",
  ),
  "ring_face_pull": MovementGuide(
    summary: "High row to face—great for rear delts and scap control.",
    targets: "Rear delts • Upper back • Rotator cuff",
    formCues: "Elbows high • Control pull • Don’t shrug",
  ),
  "ring_push_up": MovementGuide(
    summary: "Unstable push-ups—rings stay close, depth controlled.",
    targets: "Chest • Triceps • Shoulders • Core",
    formCues: "Rings close • Brace hard • Don’t let rings drift wide",
  ),
  "ring_pull_up": MovementGuide(
    summary: "Strict pull-ups on rings—keep rings close and body still.",
    targets: "Lats • Biceps • Upper back • Grip",
    formCues: "Active hang • Pull to chest • Control down",
  ),
  "false_grip_hang": MovementGuide(
    summary: "Build false grip tolerance—key for strict ring muscle-ups.",
    targets: "Forearms • Biceps • Wrist flexors",
    formCues: "Wrists over rings • Shoulders packed • Short quality holds",
  ),
  "false_grip_row": MovementGuide(
    summary: "False grip rows—huge carryover to strict transition strength.",
    targets: "Lats • Biceps • Forearms",
    formCues: "Keep false grip • Pull rings to ribs • Slow eccentric",
  ),
  "ring_l_sit_support": MovementGuide(
    summary: "L-sit on rings—stability + compression challenge.",
    targets: "Abs • Hip flexors • Shoulders • Triceps",
    formCues: "Push tall • Rings steady • Legs straight and lifted",
  ),
  "ring_support_turnout_assisted": MovementGuide(
    summary: "Assisted RTO—teach external rotation strength safely.",
    targets: "Shoulders • Rotator cuff • Chest",
    formCues: "Turn rings out • Elbows locked • Don’t shrug",
  ),
  "ring_support_rto": MovementGuide(
    summary: "RTO support—serious ring strength cornerstone.",
    targets: "Rotator cuff • Chest • Triceps • Shoulders",
    formCues: "Rings turned out • Lock elbows • Strong depression",
  ),
  "ring_dip_negative": MovementGuide(
    summary: "Slow eccentric ring dip—rings close, elbows track, stay stable.",
    targets: "Triceps • Chest • Shoulders",
    formCues: "Rings close • Slow lower • Don’t collapse shoulders",
  ),
  "ring_dip": MovementGuide(
    summary: "Strict ring dips—control depth and finish with solid lockout.",
    targets: "Triceps • Chest • Shoulders • Core",
    formCues: "Rings close • Shoulders packed • Full lockout",
  ),
  "ring_turnout_dip": MovementGuide(
    summary: "Dip with RTO finish—big step toward advanced ring strength.",
    targets: "Triceps • Chest • Rotator cuff",
    formCues: "Turn out at top • Lock elbows • Stay steady",
  ),
  "ring_transition_low": MovementGuide(
    summary: "Low-ring transition drill—false grip, close rings, smooth turnover.",
    targets: "Biceps • Lats • Chest • Triceps",
    formCues: "False grip • Keep rings tight • Elbows fast over",
  ),
  "ring_muscle_up": MovementGuide(
    summary: "Strict ring muscle-up—false grip + controlled transition.",
    targets: "Lats • Biceps • Chest • Triceps • Forearms",
    formCues: "False grip • Pull to sternum • Smooth turnover to deep dip",
  ),
  "ring_inverted_hang": MovementGuide(
    summary: "Inverted hang—control shoulder position and stay tight.",
    targets: "Core • Shoulders • Upper back",
    formCues: "Rings close • Tight line • No loose arching",
  ),
  "ring_tuck_back_lever": MovementGuide(
    summary: "Tuck back lever on rings—active shoulders, glutes on, no pike.",
    targets: "Shoulders • Chest • Lats • Core",
    formCues: "Pack shoulders • Glutes tight • Keep hips level",
  ),
  "ring_back_lever": MovementGuide(
    summary: "Full back lever on rings—high shoulder demand, progress slowly.",
    targets: "Shoulders • Chest • Lats • Core",
    formCues: "Active shoulders • Straight body • Controlled hold",
  ),
  "ring_cross_lean": MovementGuide(
    summary: "Cross lean—tendon prep for assisted cross. Be conservative.",
    targets: "Chest • Shoulders • Biceps tendon • Rotator cuff",
    formCues: "Small lean • Elbows mostly straight • Pain-free only",
    mistakes: "Chasing depth • Sharp elbow/shoulder pain • Too much volume",
  ),
  "ring_assisted_iron_cross": MovementGuide(
    summary: "Band-assisted cross—build strength safely with strict control.",
    targets: "Chest • Shoulders • Biceps tendon • Lats",
    formCues: "Use enough band • Short holds • Perfect shoulder position",
    mistakes: "Under-banding • Dropping fast • Ignoring tendon pain",
  ),
  "iron_cross": MovementGuide(
    summary: "Full iron cross—extreme ring strength. Treat as tendon-heavy skill.",
    targets: "Chest • Shoulders • Biceps tendon • Lats",
    formCues: "Warm up thoroughly • Very low volume • Stop if pain",
    mistakes: "Grinding reps • Cold attempts • High volume",
  ),
  "assisted_maltese": MovementGuide(
    summary: "Band-assisted maltese—very demanding; progress slowly and carefully.",
    targets: "Chest • Front delts • Biceps tendon • Core",
    formCues: "Strong support base • Use bands • Short holds, strict line",
    mistakes: "Too deep too soon • Shoulder pain • Skipping prep work",
  ),
  "maltese": MovementGuide(
    summary: "Full maltese—elite strength. Extremely high stress on shoulders/tendons.",
    targets: "Chest • Front delts • Biceps tendon • Core",
    formCues: "Huge base strength first • Low volume • Perfect control",
    mistakes: "Maxing often • Poor prep • Painful holds",
  ),
  "ring_biceps_curl": MovementGuide(
    summary: "Bodyweight curl on rings—control the eccentric and keep elbows up.",
    targets: "Biceps • Forearms • Upper back",
    formCues: "Elbows high • Curl smoothly • Slow lowering",
  ),
  "ring_triceps_extension": MovementGuide(
    summary: "Ring triceps extensions—keep elbows tucked and move slowly.",
    targets: "Triceps • Shoulders (stability) • Core",
    formCues: "Elbows in • Neutral ribs • Control bottom position",
  ),
  "ring_fly": MovementGuide(
    summary: "Assisted chest fly—only go as deep as you can control.",
    targets: "Chest • Front delts • Biceps tendon",
    formCues: "Shoulders packed • Small range first • Controlled return",
    mistakes: "Overstretching • Losing shoulder position • Dropping fast",
  ),
  "ring_support_swings": MovementGuide(
    summary: "Small controlled swings in support—teach stability under motion.",
    targets: "Shoulders • Core • Triceps",
    formCues: "Tiny swings • Rings steady • Stay hollow",
  ),
  "ring_external_rotation": MovementGuide(
    summary: "Light shoulder health drill—slow, controlled external rotation.",
    targets: "Rotator cuff • Rear delts • Scap stabilizers",
    formCues: "Pain-free range • Slow tempo • Keep shoulder packed",
  ),
};
