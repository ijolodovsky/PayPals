  import 'package:flutter/material.dart';

IconData getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'comida':
        return Icons.fastfood;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.local_movies;
      case 'salud':
        return Icons.favorite;
      case 'alojamiento':
        return Icons.hotel;
      default:
        return Icons.category;
    }
  }