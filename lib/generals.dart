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
      case 'hogar':
        return Icons.home;
      case 'sube':
        return Icons.credit_card;
      case 'compras':
        return Icons.shopping_cart;
      case 'educación':
        return Icons.school;
      case 'ropa':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }