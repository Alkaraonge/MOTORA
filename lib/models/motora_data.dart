import 'package:flutter/material.dart';

@immutable
class Vehicle {
  const Vehicle({
    required this.name,
    required this.category,
    required this.price,
    required this.year,
    required this.status,
    required this.icon,
  });

  final String name;
  final String category;
  final String price;
  final String year;
  final String status;
  final IconData icon;
}

const List<Vehicle> vehicles = <Vehicle>[
  Vehicle(
    name: 'تويوتا كامري',
    category: 'سيدان • أبيض لؤلؤي',
    price: '٣٨,٥٠٠,٠٠٠ د.ع',
    year: '٢٠٢٤',
    status: 'متاحة',
    icon: Icons.directions_car_filled_rounded,
  ),
  Vehicle(
    name: 'كيا سبورتاج',
    category: 'دفع رباعي • أسود',
    price: '٤٢,٠٠٠,٠٠٠ د.ع',
    year: '٢٠٢٤',
    status: 'محجوزة',
    icon: Icons.airport_shuttle_rounded,
  ),
  Vehicle(
    name: 'هيونداي توسان',
    category: 'دفع رباعي • رصاصي',
    price: '٣٦,٧٥٠,٠٠٠ د.ع',
    year: '٢٠٢٣',
    status: 'متاحة',
    icon: Icons.directions_car_rounded,
  ),
];

@immutable
class SaleContract {
  const SaleContract({
    required this.number,
    required this.buyer,
    required this.vehicle,
    required this.date,
    required this.amount,
  });

  final String number;
  final String buyer;
  final String vehicle;
  final String date;
  final String amount;
}

const List<SaleContract> contracts = <SaleContract>[
  SaleContract(
    number: 'ZC-٢٠٣٦-٠١٨',
    buyer: 'أحمد كريم',
    vehicle: 'تويوتا كامري ٢٠٢٤',
    date: '٢٠ تشرين الأول ٢٠٢٦',
    amount: '٣٨,٥٠٠,٠٠٠ د.ع',
  ),
  SaleContract(
    number: 'ZC-٢٠٣٦-٠١٧',
    buyer: 'محمد علي',
    vehicle: 'كيا سبورتاج ٢٠٢٤',
    date: '١٨ تشرين الأول ٢٠٢٦',
    amount: '٤٢,٠٠٠,٠٠٠ د.ع',
  ),
];
