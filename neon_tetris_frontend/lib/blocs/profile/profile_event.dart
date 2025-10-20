import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class ProfileFetched extends ProfileEvent {}

class AvatarUpdateRequested extends ProfileEvent {
  final Uint8List imageBytes;
  final String filename;
  
  const AvatarUpdateRequested({required this.imageBytes, required this.filename});
}