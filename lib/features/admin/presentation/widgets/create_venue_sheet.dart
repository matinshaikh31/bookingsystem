import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../venue/data/venue_fb_repo.dart';
import '../../../venue/domain/models/venue_model.dart';
import '../../../venue/presentation/cubit/venue_form_cubit.dart';
import '../../../venue/presentation/cubit/venue_form_state.dart';

class CreateVenueSheet extends StatelessWidget {
  final VenueModel? venue;
  const CreateVenueSheet({super.key, this.venue});

  static Future<void> show(BuildContext context, {VenueModel? venue}) {
    final repo = context.read<VenueFbRepo>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: BlocProvider<VenueFormCubit>(
          create: (context) {
            final cubit = VenueFormCubit(venueFbRepo: repo);
            if (venue != null) {
              cubit.initializeForEdit(venue);
            }
            return cubit;
          },
          child: CreateVenueSheet(venue: venue),
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    final cubit = context.read<VenueFormCubit>();
    if (!(cubit.formKey.currentState?.validate() ?? false)) return;
    cubit.submitVenue(editId: venue?.id);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = venue != null;
    final cubit = context.read<VenueFormCubit>();

    return BlocConsumer<VenueFormCubit, VenueFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit
                    ? 'Venue updated successfully'
                    : 'Venue created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
              Navigator.pop(context);
            }
          });
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: cubit.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isEdit ? 'Edit venue' : 'New venue',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cubit.nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Urban Turf by Sports Ocean',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cubit.locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Sector 5, Kolkata',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a location'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cubit.sportCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sport (e.g. Football, Cricket)',
                    hintText: 'Football',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a sport' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cubit.priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price per slot (₹)',
                    hintText: '600',
                  ),
                  validator: (v) {
                    final p = double.tryParse((v ?? '').trim());
                    if (p == null || p < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _onSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Update venue' : 'Save venue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
