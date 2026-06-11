
import 'package:freezed_annotation/freezed_annotation.dart';
part 'map_state.freezed.dart';
@freezed
class MapState with _$MapState {
  const factory MapState.initial() = _Initial;
  const factory MapState.mapIndex(String? address) = MapIndex;
}
