enum AlertType {
  speedCamera,
  speedSign,
  trafficLight,
  noOvertakingStart,
  noOvertakingEnd,
  residentialAreaStart,
  residentialAreaEnd,
  restArea,
  noParking,
  noEntry,
  noTurn,
  noUTurn,
  infoSign,
  unknown;

  String get displayLabel => switch (this) {
    AlertType.speedCamera => 'Camera giám sát',
    AlertType.speedSign => 'Biển báo tốc độ',
    AlertType.trafficLight => 'Đèn tín hiệu giao thông',
    AlertType.noOvertakingStart => 'Cấm vượt',
    AlertType.noOvertakingEnd => 'Hết cấm vượt',
    AlertType.residentialAreaStart => 'Vào khu dân cư',
    AlertType.residentialAreaEnd => 'Hết khu dân cư',
    AlertType.restArea => 'Trạm dừng nghỉ',
    AlertType.noParking => 'Cấm đỗ xe',
    AlertType.noEntry => 'Cấm đi vào',
    AlertType.noTurn => 'Cấm rẽ',
    AlertType.noUTurn => 'Cấm quay đầu',
    AlertType.infoSign => 'Biển thông tin',
    AlertType.unknown => 'Khác',
  };
}

const Set<AlertType> csvAlertTypes = {
  AlertType.speedCamera, AlertType.speedSign, AlertType.trafficLight,
  AlertType.noOvertakingStart, AlertType.noOvertakingEnd,
  AlertType.residentialAreaStart, AlertType.residentialAreaEnd,
  AlertType.restArea, AlertType.noParking, AlertType.noEntry,
  AlertType.noTurn, AlertType.noUTurn, AlertType.infoSign,
};
