import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState.initial());

  double? lat;
  double? lng;
  String? address;

  void changeAddress({required String newAddress}) {
    address = newAddress;
    emit(MapState.mapIndex(newAddress));
  }
}
