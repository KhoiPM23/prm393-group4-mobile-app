import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/repositories/mock_property_repository.dart';
import '../../domain/entities/property_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/property_card.dart';

class HostPropertyListScreen extends StatelessWidget {
  const HostPropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const Scaffold();

    final repo = MockPropertyRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Khách sạn đang quản lý'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: FutureBuilder<List<PropertyEntity>>(
        future: repo.getPropertiesByHost(authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final properties = snapshot.data ?? [];
          if (properties.isEmpty) {
            return const Center(child: Text('Bạn chưa quản lý khách sạn nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final p = properties[index];
              final formattedPrice = '${p.pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ';

              return PropertyCard(
                title: p.title,
                location: p.location,
                priceText: formattedPrice,
                rating: p.rating,
                imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                onTap: () {
                  Navigator.of(context).pushNamed('/property-detail', arguments: p);
                },
              );
            },
          );
        },
      ),
    );
  }
}
