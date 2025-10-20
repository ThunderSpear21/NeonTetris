import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isHapticsEnabled;
  final double musicVolume;

  const SettingsState({
    this.isHapticsEnabled = true,
    this.musicVolume = 0.5,
  });

  SettingsState copyWith({
    bool? isHapticsEnabled,
    double? musicVolume,
  }) {
    return SettingsState(
      isHapticsEnabled: isHapticsEnabled ?? this.isHapticsEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }

  @override
  List<Object> get props => [isHapticsEnabled, musicVolume];
}