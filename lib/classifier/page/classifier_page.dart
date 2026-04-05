import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orchid_classifier/classifier/cubit/classifier_cubit.dart';
import 'package:orchid_classifier/classifier/widgets/error_card.dart';
import 'package:orchid_classifier/classifier/widgets/example_images_card.dart';
import 'package:orchid_classifier/classifier/widgets/orchid_info_card.dart';
import 'package:orchid_classifier/classifier/widgets/result_card.dart';
import 'package:orchid_classifier/core/theme/orchid_colors.dart';
import 'package:orchid_classifier/setting/settings_page.dart';

class ClassifierPage extends StatefulWidget {
  const ClassifierPage({super.key});

  @override
  State<ClassifierPage> createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.orchidColors;

    return BlocBuilder<ClassifierCubit, ClassifierState>(
      builder: (context, state) {
        final cubit = context.read<ClassifierCubit>();

        return Scaffold(
          body: Stack(
            children: [
              const _AnimatedBackground(),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      pinned: false,
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      titleSpacing: 16,
                      title: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [colors.primary, colors.accent],
                              ),
                            ),
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orchid Vision AI',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Detect • Crop • Classify',
                                  style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SettingsPage()),
                              );
                            },
                            icon: Icon(
                              Icons.settings_rounded,
                              color: colors.text,
                            ),
                            tooltip: 'Cài đặt',
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        child: Column(
                          children: [
                            // 1. Phân Ảnh Đầu Vào
                            _buildMainImageSection(context, state, cubit),
                            const SizedBox(height: 18),
                            
                            // 2. Action Panel
                            _buildActionPanel(context, state, cubit),
                            
                            // 3. Hiển thị Lỗi (nếu có)
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 20),
                              ErrorCard(message: state.errorMessage!),
                            ],

                            // 4. Kết quả & Info Card
                            if (state.isLoading && state.imageFile != null) ...[
                              const SizedBox(height: 20),
                              const ResultCardShimmer(),
                            ] else if (state.response != null) ...[
                              const SizedBox(height: 20),
                              ResultCard(
                                response: state.response!,
                                imageFile: state.imageFile,
                              ),
                              if (state.exampleImages.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ExampleImagesCard(
                                  title: state.response!.topClass,
                                  imagePaths: state.exampleImages,
                                ),
                              ],
                              if (state.orchidInfo != null) ...[
                                const SizedBox(height: 12),
                                OrchidInfoCard(
                                  title: state.response!.topClass,
                                  content: state.orchidInfo!,
                                ),
                              ],
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isLoading && state.imageFile == null) 
                 const _AiLoadingOverlay(), // Chỉ hiện mờ trùm lên nếu load màn hinh ko có ảnh
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainImageSection(
    BuildContext context,
    ClassifierState state,
    ClassifierCubit cubit,
  ) {
    final colors = context.orchidColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _glassCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Ảnh đầu vào', Icons.image_search_rounded),
          const SizedBox(height: 14),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 380, // Chiều cao ảnh to bự như mockup bạn muốn
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: state.imageFile == null
                      ? _buildImagePlaceholder(context)
                      : Image.file(
                          state.imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
              // Nút Floating Camera / Gallery góc phải
              Positioned(
                right: 14,
                top: 14,
                child: Column(
                  children: [
                    _floatingActionCircle(
                      icon: Icons.camera_alt_rounded,
                      colors: [colors.primary, colors.secondary],
                      onTap: state.isLoading
                          ? null
                          : () => cubit.pickImage(ImageSource.camera),
                    ),
                    const SizedBox(height: 10),
                    _floatingActionCircle(
                      icon: Icons.photo_library_rounded,
                      colors: [colors.secondary, colors.primary],
                      onTap: state.isLoading
                          ? null
                          : () => cubit.pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (state.imageFile != null) ...[
            const SizedBox(height: 14),
             _glassButton(
                  context,
                  label: 'Sửa ảnh (Cắt thủ công)',
                  icon: Icons.crop_rounded,
                  onTap: state.isLoading
                      ? null
                      : () => cubit.cropCurrentImage(),
                  color: colors.primary,
                  isFullWidth: true,
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context, ClassifierState state, ClassifierCubit cubit) {
    final colors = context.orchidColors;

    return _glassCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'AI Actions', Icons.bolt_rounded),
          const SizedBox(height: 14),
          // Nút Big Action: Detect + Classify
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                if (state.imageFile != null)
                  BoxShadow(
                    color: colors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: _gradientButton(
              label: 'Detect + Classify',
              icon: Icons.auto_awesome_rounded,
              onTap: state.isLoading || state.imageFile == null
                  ? null
                  : cubit.detectAndClassifyCurrentImage,
              colors: [colors.primary, colors.accent],
              big: true,
            ),
          ),
          const SizedBox(height: 14),
          // Hai Nút nhỏ nằm ngang: Detect / Classify
          Row(
            children: [
              Expanded(
                child: _glassActionCard(
                  context: context,
                  title: 'Detect',
                  subtitle: 'Chỉ cắt\nvùng hoa và\nlưu crop',
                  icon: Icons.center_focus_strong_rounded,
                  color: colors.secondary,
                  onTap: state.isLoading || state.imageFile == null
                      ? null
                      : cubit.detectCurrentImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _glassActionCard(
                  context: context,
                  title: 'Classify',
                  subtitle: 'Nếu chưa\ndetect sẽ\nphân loại gốc',
                  icon: Icons.psychology_alt_rounded,
                  color: colors.warning,
                  onTap: state.isLoading || state.imageFile == null
                      ? null
                      : cubit.classify,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colors = context.orchidColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : colors.card.withOpacity(0.95),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 68, color: colors.muted),
            const SizedBox(height: 12),
            Text(
              'Chưa có ảnh đầu vào',
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bấm camera hoặc thư viện ở góc phải',
              style: TextStyle(color: colors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required BuildContext context, required Widget child}) {
    final colors = context.orchidColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : colors.card.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.22)
                : colors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _glassActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.orchidColors;

    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: color.withOpacity(isDark ? 0.15 : 0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Icon(icon, color: color, size: 24),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       title,
                       style: TextStyle(
                         color: colors.text,
                         fontWeight: FontWeight.w700,
                         fontSize: 15,
                       ),
                     ),
                     const SizedBox(height: 6),
                     Text(
                       subtitle,
                       style: TextStyle(
                         color: colors.muted,
                         fontSize: 12,
                         height: 1.4,
                       ),
                     )
                   ],
                 )
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final colors = context.orchidColors;

    return Row(
      children: [
        Icon(icon, color: colors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required List<Color> colors,
    bool big = false,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onTap == null ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: big ? 18 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: big ? 26 : 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: big ? 17 : 15,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    bool isFullWidth = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.orchidColors;

    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingActionCircle({
    required IconData icon,
    required List<Color> colors,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.orchidColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(color: colors.bg),
        Positioned(
          top: -80,
          left: -50,
          child: _orb(
            size: 220,
            color: colors.primary.withOpacity(isDark ? 0.18 : 0.12),
          ),
        ),
        Positioned(
          right: -60,
          top: 120,
          child: _orb(
            size: 180,
            color: colors.secondary.withOpacity(isDark ? 0.12 : 0.10),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 40,
          child: _orb(
            size: 200,
            color: colors.accent.withOpacity(isDark ? 0.12 : 0.10),
          ),
        ),
      ],
    );
  }

  Widget _orb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}

class _AiLoadingOverlay extends StatefulWidget {
  const _AiLoadingOverlay();

  @override
  State<_AiLoadingOverlay> createState() => _AiLoadingOverlayState();
}

class _AiLoadingOverlayState extends State<_AiLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.orchidColors;

    return Container(
      color: Colors.black.withOpacity(0.42),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 1).animate(_controller),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.accent],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Analyzing with AI...',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(minHeight: 10),
              ),
              const SizedBox(height: 12),
              Text(
                'Đang chạy luồng phân tích nhận dạng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}