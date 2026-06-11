/// مسارات أيقونات الـ SVG (منظّمة حسب الفئة).
class AppIcons {
  AppIcons._();

  static const String _nav = 'assets/icons/navigation';
  static const String _services = 'assets/icons/services';
  static const String _common = 'assets/icons/common';
  static const String _vehicles = 'assets/icons/vehicles';
  static const String _orders = 'assets/icons/orders';

  // navigation
  static const String home = '$_nav/home.svg';
  static const String orders = '$_nav/orders.svg';
  static const String vehicles = '$_nav/vehicles.svg';
  static const String chat = '$_nav/chat.svg';
  static const String profile = '$_nav/profile.svg';

  // services
  static const String towTruckNormal = '$_services/tow_truck_normal.svg';
  static const String towTruckHydraulic = '$_services/tow_truck_hydraulic.svg';
  static const String quickRescue = '$_services/quick_rescue.svg';

  // common
  static const String notification = '$_common/notification.svg';
  static const String support = '$_common/support.svg';
  static const String arrowLeft = '$_common/arrow_left.svg';
  static const String edit = '$_common/edit.svg';
  static const String delete = '$_common/delete.svg';
  static const String add = '$_common/add.svg';
  static const String camera = '$_common/camera.svg';
  static const String gallery = '$_common/gallery.svg';
  static const String checkCircle = '$_common/check_circle.svg';

  // vehicles
  static const String car = '$_vehicles/car.svg';
  static const String carPlate = '$_vehicles/car_plate.svg';
  static const String carColor = '$_vehicles/car_color.svg';
  static const String chassis = '$_vehicles/chassis.svg';

  // orders (تُستخدم في مراحل لاحقة)
  static const String breakdown = '$_orders/breakdown.svg';
  static const String accident = '$_orders/accident.svg';
}
