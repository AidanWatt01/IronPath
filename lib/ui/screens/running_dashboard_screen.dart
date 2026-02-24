import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../../domain/running_activity.dart";
import "../../domain/running_connector_credentials.dart";
import "../../domain/running_goal.dart";
import "../../domain/running_plan_service.dart";
import "../../domain/running_strava_oauth_config.dart";
import "../../domain/running_strava_oauth_service.dart";
import "../../domain/training_mode.dart";
import "../../state/providers.dart";

class RunningDashboardScreen extends ConsumerStatefulWidget {
  const RunningDashboardScreen({super.key});

  @override
  ConsumerState<RunningDashboardScreen> createState() =>
      _RunningDashboardScreenState();
}

class _RunningDashboardScreenState
    extends ConsumerState<RunningDashboardScreen> {
  RunningWatchProvider _selectedProvider = RunningWatchProvider.garmin;
  bool _syncing = false;
  bool _authorizingStrava = false;
  String? _syncFeedback;
  String? _pendingStravaState;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _authorizingStrava = false;
          _pendingStravaState = null;
          _syncFeedback = "Could not complete Strava OAuth callback.";
        });
      },
    );
    _checkInitialLink();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialLink() async {
    final initial = await _appLinks.getInitialLink();
    if (!mounted || initial == null) {
      return;
    }
    await _handleIncomingLink(initial);
  }

  Future<void> _switchToCalisthenics() async {
    await ref
        .read(trainingModeProvider.notifier)
        .setMode(TrainingMode.calisthenics);
  }

  Future<void> _startStravaOAuth({bool forceApproval = false}) async {
    final config = RunningStravaOAuthConfig.fromEnvironment();
    if (!config.isConfigured) {
      if (!mounted) return;
      setState(() {
        _syncFeedback =
            "Strava OAuth missing ${config.missingSettingsLabel}. Add --dart-define values.";
      });
      return;
    }

    final state = RunningStravaOAuthService.generateState();
    final uri = RunningStravaOAuthService.authorizationUri(
      config: config,
      state: state,
      forceApproval: forceApproval,
    );
    setState(() {
      _authorizingStrava = true;
      _pendingStravaState = state;
      _syncFeedback = null;
    });

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) {
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _authorizingStrava = false;
      _pendingStravaState = null;
      _syncFeedback = "Could not open Strava OAuth.";
    });
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    final config = RunningStravaOAuthConfig.fromEnvironment();
    if (!RunningStravaOAuthService.isMatchingRedirect(
      incomingUri: uri,
      redirectUri: config.redirectUri,
    )) {
      return;
    }

    final callback = RunningStravaOAuthService.parseCallback(uri);
    final expectedState = _pendingStravaState;
    if (expectedState != null && callback.state != expectedState) {
      if (!mounted) return;
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _syncFeedback = "Strava OAuth state mismatch. Try connecting again.";
      });
      return;
    }

    if (callback.error != null) {
      if (!mounted) return;
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _syncFeedback = "Strava OAuth cancelled: ${callback.error}";
      });
      return;
    }

    final code = callback.code;
    if (code == null || code.isEmpty) {
      if (!mounted) return;
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _syncFeedback = "Strava OAuth returned no authorization code.";
      });
      return;
    }

    try {
      final credential = await RunningStravaOAuthService.exchangeCode(
        config: config,
        code: code,
      );
      await ref
          .read(runningConnectorCredentialsProvider.notifier)
          .setCredential(credential);
      await ref
          .read(runningWatchSyncProvider.notifier)
          .connectProvider(RunningWatchProvider.strava);

      if (!mounted) {
        return;
      }
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _selectedProvider = RunningWatchProvider.strava;
        _syncFeedback =
            RunningStravaOAuthService.hasActivityReadScope(callback.scope)
            ? "Strava connected with OAuth."
            : "Strava connected. Consider granting activity:read_all for full imports.";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Strava connected.")));
    } on RunningStravaOAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _syncFeedback = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authorizingStrava = false;
        _pendingStravaState = null;
        _syncFeedback = "Strava OAuth failed. Try again.";
      });
    }
  }

  Future<void> _connectOrDisconnect({required bool connect}) async {
    if (connect) {
      if (_selectedProvider == RunningWatchProvider.manual) {
        if (!mounted) return;
        setState(() {
          _syncFeedback = "Manual runs do not require a connector.";
        });
        return;
      }

      if (_selectedProvider == RunningWatchProvider.strava) {
        await _startStravaOAuth();
        return;
      }

      await ref
          .read(runningWatchSyncProvider.notifier)
          .connectProvider(_selectedProvider);
      if (!mounted) return;
      setState(() {
        _syncFeedback =
            "${runningWatchProviderLabel(_selectedProvider)} connected.";
      });
      return;
    }

    await ref
        .read(runningWatchSyncProvider.notifier)
        .disconnectProvider(_selectedProvider);
    if (!mounted) return;
    setState(() {
      _syncFeedback =
          "${runningWatchProviderLabel(_selectedProvider)} disconnected.";
    });
  }

  Future<void> _syncNow() async {
    setState(() {
      _syncing = true;
      _syncFeedback = null;
    });

    try {
      final result = await ref
          .read(runningWatchSyncProvider.notifier)
          .syncFromProvider(_selectedProvider);
      if (!mounted) return;
      setState(() {
        _syncFeedback = result.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  Future<void> _openManualRunDialog() async {
    final distanceController = TextEditingController();
    final durationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? errorText;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDateTime() async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(
                  const Duration(days: 365 * 3),
                ),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (pickedDate == null) {
                return;
              }
              if (!context.mounted) {
                return;
              }

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDate),
              );
              if (pickedTime == null) {
                return;
              }
              if (!context.mounted) {
                return;
              }

              setSheetState(() {
                selectedDate = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Log Manual Run",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: distanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: "Distance (km)",
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: "Duration (minutes)",
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: pickDateTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_formatDateTime(selectedDate)),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () async {
                      final distance = double.tryParse(
                        distanceController.text.trim().replaceAll(",", "."),
                      );
                      final durationMinutes = int.tryParse(
                        durationController.text.trim(),
                      );
                      if (distance == null ||
                          distance <= 0 ||
                          durationMinutes == null ||
                          durationMinutes <= 0) {
                        setSheetState(() {
                          errorText =
                              "Enter valid distance and duration values.";
                        });
                        return;
                      }

                      await ref
                          .read(runningActivitiesProvider.notifier)
                          .addManualRun(
                            startedAt: selectedDate,
                            distanceKm: distance,
                            durationSeconds: durationMinutes * 60,
                          );

                      if (!mounted) {
                        return;
                      }
                      if (!sheetContext.mounted) {
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Manual run added to adaptation data."),
                        ),
                      );
                    },
                    child: const Text("Add run"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    distanceController.dispose();
    durationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(runningGoalProvider);
    final plan = ref.watch(runningPlanProvider);
    final activities = ref
        .watch(runningActivitiesProvider)
        .maybeWhen(data: (x) => x, orElse: () => const <RunningActivity>[]);
    final watchSync = ref
        .watch(runningWatchSyncProvider)
        .maybeWhen(
          data: (x) => x,
          orElse: () => const RunningWatchSyncState(
            connectedProviders: <RunningWatchProvider>{},
            totalImportedRuns: 0,
          ),
        );
    final connectorCreds = ref
        .watch(runningConnectorCredentialsProvider)
        .maybeWhen(
          data: (x) => x,
          orElse: () =>
              const <RunningWatchProvider, RunningConnectorCredential>{},
        );
    final connected = watchSync.connectedProviders.contains(_selectedProvider);
    final stravaCred = connectorCreds[RunningWatchProvider.strava];
    final stravaOauthConfig = RunningStravaOAuthConfig.fromEnvironment();
    final stravaConnected =
        watchSync.connectedProviders.contains(RunningWatchProvider.strava) &&
        (stravaCred?.hasAccessToken ?? false);
    final connectorProviders = RunningWatchProvider.values
        .where((provider) => provider != RunningWatchProvider.manual)
        .toList(growable: false);
    final selectedProviderLastSync = watchSync.lastSyncedForProvider(
      _selectedProvider,
    );
    final connectedProviderLabels = watchSync.connectedProviders
        .where((provider) => provider != RunningWatchProvider.manual)
        .map(runningWatchProviderLabel)
        .toList(growable: false);

    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Running Dashboard",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _switchToCalisthenics,
                icon: const Icon(Icons.fitness_center),
                label: const Text("Calisthenics"),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Adaptive plan + watch sync.",
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          goalAsync.when(
            data: (goal) {
              if (goal == null) {
                return _InfoCard(
                  title: "No running goal yet",
                  subtitle:
                      "Set a goal in the Goals tab to generate your plan.",
                );
              }

              return _InfoCard(
                title: goal.type == RunningGoalType.getFaster
                    ? "Goal: Get Faster"
                    : "Goal: Distance by Date",
                subtitle:
                    "${goal.targetDistanceKm.toStringAsFixed(1)} km by ${_formatDate(goal.targetDate)}",
              );
            },
            loading: () => const _InfoCard(
              title: "Loading goal",
              subtitle: "Fetching saved running goal...",
            ),
            error: (err, _) =>
                _InfoCard(title: "Goal unavailable", subtitle: err.toString()),
          ),
          const SizedBox(height: 12),
          if (plan == null)
            const _InfoCard(
              title: "No plan yet",
              subtitle: "Create a goal to see weekly progression.",
            )
          else ...[
            _InfoCard(title: plan.headline, subtitle: plan.summary),
            const SizedBox(height: 10),
            _InfoCard(
              title:
                  "Feasibility: ${runningFeasibilityLabel(plan.feasibility)}",
              subtitle:
                  "${plan.feasibilityReason}\nEstimated finish: ${_formatMinutes(plan.estimatedFinishMinutes)}",
            ),
            const SizedBox(height: 10),
            _InfoCard(
              title: "Adaptation",
              subtitle:
                  "${plan.adaptation.message}\nRecent load: ${plan.adaptation.recentDistanceKm.toStringAsFixed(1)} / ${plan.adaptation.expectedDistanceKm.toStringAsFixed(1)} km (21d)\nVolume x${plan.adaptation.volumeMultiplier.toStringAsFixed(2)} | Intensity x${plan.adaptation.intensityMultiplier.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 10),
            if (plan.nextWorkout != null)
              _InfoCard(
                title:
                    "Next: ${plan.nextWorkout!.title} (${plan.nextWorkout!.dayLabel})",
                subtitle:
                    "${plan.nextWorkout!.distanceKm.toStringAsFixed(1)} km - ${plan.nextWorkout!.description}\n${plan.nextWorkout!.prescription}",
              ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Watch Integration",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RunningWatchProvider>(
                  initialValue: _selectedProvider,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: "Source",
                  ),
                  items: connectorProviders.map((provider) {
                    return DropdownMenuItem<RunningWatchProvider>(
                      value: provider,
                      child: Text(runningWatchProviderLabel(provider)),
                    );
                  }).toList(),
                  onChanged: (next) {
                    if (next == null) return;
                    setState(() {
                      _selectedProvider = next;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            (_authorizingStrava &&
                                _selectedProvider ==
                                    RunningWatchProvider.strava)
                            ? null
                            : () => _connectOrDisconnect(connect: !connected),
                        child: Text(connected ? "Disconnect" : "Connect"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _syncing || _authorizingStrava
                            ? null
                            : _syncNow,
                        child: _syncing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Sync now"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openManualRunDialog,
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Log manual run"),
                ),
                if (_selectedProvider == RunningWatchProvider.strava) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _authorizingStrava
                        ? null
                        : () =>
                              _startStravaOAuth(forceApproval: stravaConnected),
                    icon: _authorizingStrava
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.link),
                    label: Text(
                      stravaConnected
                          ? "Reconnect Strava OAuth"
                          : "Connect Strava OAuth",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    !stravaOauthConfig.isConfigured
                        ? "OAuth config missing: ${stravaOauthConfig.missingSettingsLabel}"
                        : !stravaConnected
                        ? "OAuth status: not connected"
                        : "OAuth status: connected",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (stravaCred?.expiresAt != null)
                    Text(
                      "Token expires: ${_formatDateTime(stravaCred!.expiresAt!)}",
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if ((stravaCred?.athleteId ?? "").isNotEmpty)
                    Text(
                      "Athlete ID: ${stravaCred!.athleteId}",
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  "Connected: ${connectedProviderLabels.isEmpty ? "none" : connectedProviderLabels.join(", ")}",
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Imported runs: ${watchSync.totalImportedRuns}",
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedProviderLastSync != null)
                  Text(
                    "${runningWatchProviderLabel(_selectedProvider)} last sync: ${_formatDateTime(selectedProviderLastSync)}",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (watchSync.lastSyncedAt != null)
                  Text(
                    "Last sync: ${_formatDateTime(watchSync.lastSyncedAt!)}",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if ((watchSync.lastSyncMessage ?? "").trim().isNotEmpty ||
                    (_syncFeedback ?? "").trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _syncFeedback ?? watchSync.lastSyncMessage ?? "",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  "Apple Health and Health Connect use native sync. Strava uses OAuth. Garmin and COROS remain pending OAuth/API connectors.",
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (activities.isNotEmpty)
            _InfoCard(
              title: "Recent Synced Runs",
              subtitle: activities
                  .take(3)
                  .map(
                    (x) =>
                        "${_formatDate(x.startedAt)} ${x.distanceKm.toStringAsFixed(1)} km in ${_formatMinutes((x.durationSeconds / 60).round())}",
                  )
                  .join("\n"),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _formatDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, "0");
    final day = date.day.toString().padLeft(2, "0");
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "${date.year}-$month-$day $hour:$minute";
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return "${h}h ${m.toString().padLeft(2, "0")}m";
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
