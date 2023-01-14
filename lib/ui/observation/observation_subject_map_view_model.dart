import 'dart:ffi';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:stacked/stacked.dart';

class ObservationSubjectMapViewModel extends BaseViewModel {
  IObservationRecordService observationService =
      locator<IObservationRecordService>();

  int definitionId;
  Position? currentPosition;

  GoogleMapController? controller;

  final ReactiveList<ObservationSubjectRecord> _subjects =
      ReactiveList<ObservationSubjectRecord>();

  ObservationSubjectMapViewModel(this.definitionId) {
    setBusy(true);
    _getCurrentLocation();
  }

  List<ObservationSubjectRecord> get subjects => _subjects;

  fetch(double topLeftX, double topLeftY, double bottomRightX,
      double bottomRightY) async {
    _subjects.clear();
    _subjects.addAll(await observationService.fetchAllSubjectRecordsInBounded(
        definitionId, topLeftX, topLeftY, bottomRightX, bottomRightY));
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setBusy(false);
  }
}
