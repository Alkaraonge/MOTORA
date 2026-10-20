import 'package:flutter/material.dart';

@immutable
class Vehicle {
  const Vehicle({
    required this.name,
    required this.category,
    required this.price,
    required this.power,
    required this.range,
    required this.icon,
  });

  final String name;
  final String category;
  final String price;
  final String power;
  final String range;
  final IconData icon;
}

const List<Vehicle> vehicles = <Vehicle>[
  Vehicle(
    name: 'MOTORA ONE',
    category: 'سيدان تنفيذية',
    price: 'ابتداءً من ٢١٨,٠٠٠ ر.س',
    power: '٤٨٩ حصان',
    range: '٦٢٠ كم',
    icon: Icons.directions_car_filled_rounded,
  ),
  Vehicle(
    name: 'MOTORA X',
    category: 'دفع رباعي فاخر',
    price: 'ابتداءً من ٢٨٥,٠٠٠ ر.س',
    power: '٥٣٠ حصان',
    range: '٥٨٠ كم',
    icon: Icons.airport_shuttle_rounded,
  ),
  Vehicle(
    name: 'MOTORA S',
    category: 'كوبيه رياضية',
    price: 'ابتداءً من ٣٤٩,٠٠٠ ر.س',
    power: '٦٨٠ حصان',
    range: '٥١٠ كم',
    icon: Icons.electric_car_rounded,
  ),
];

@immutable
class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
}

const List<ServiceItem> services = <ServiceItem>[
  ServiceItem(
    title: 'العناية الذكية',
    subtitle: 'موعدك القادم بعد ٢,٤٥٠ كم',
    icon: Icons.car_repair_rounded,
    status: 'ممتاز',
  ),
  ServiceItem(
    title: 'المساعدة على الطريق',
    subtitle: 'دعم على مدار الساعة أينما كنت',
    icon: Icons.support_agent_rounded,
    status: 'متاح',
  ),
  ServiceItem(
    title: 'الشحن المنزلي',
    subtitle: 'محطة الشحن متصلة وتعمل بكفاءة',
    icon: Icons.ev_station_rounded,
    status: 'متصل',
  ),
  ServiceItem(
    title: 'MOTORA Shield',
    subtitle: 'تغطية شاملة حتى أكتوبر ٢٠٢٩',
    icon: Icons.verified_user_rounded,
    status: 'نشط',
  ),
];
