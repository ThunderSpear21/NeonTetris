import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class HapticsToggled extends SettingsEvent {}

class MusicVolumeChanged extends SettingsEvent {
  final double volume;

  const MusicVolumeChanged(this.volume);

  @override
  List<Object> get props => [volume];
}
