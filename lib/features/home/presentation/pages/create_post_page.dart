import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/features/home/presentation/widgets/new_post_bottom_sheet.dart';
import 'package:agrobravo/features/home/presentation/widgets/select_mission_dialog.dart';

class CreatePostPage extends StatefulWidget {
  final List<String> initialImages;
  final PostEntity? postToEdit;

  const CreatePostPage({
    super.key,
    required this.initialImages,
    this.postToEdit,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late List<String> _images;
  int _selectedImageIndex = 0;
  bool _isPrivate = false;
  final TextEditingController _captionController = TextEditingController();

  List<MissionEntity> _missions = [];

  MissionEntity? _selectedMission;
  bool _isSharing = false;

  bool get _isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _images = List.from(widget.postToEdit!.images);
      _captionController.text = widget.postToEdit!.caption;
      _isPrivate = widget.postToEdit!.isPrivate;
    } else {
      _images = List.from(widget.initialImages);
    }
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final result = await getIt<FeedRepository>().getUserMissions();
    result.fold((l) => null, (r) {
      setState(() {
        _missions = r;

        if (_isEditing && widget.postToEdit!.missionName != null) {
          // Try to find the mission by name or ID if available
          try {
            _selectedMission = _missions.firstWhere(
              (m) =>
                  m.name == widget.postToEdit!.missionName ||
                  m.id == widget.postToEdit!.missionId,
            );
          } catch (_) {
            // Mission not found or user no longer has access
          }
        } else if (_missions.isNotEmpty && _selectedMission == null) {
          // Default to first if creating new post
          _selectedMission = _missions.first;
        }
      });
    });
  }

  Future<void> _addMoreImages() async {
    final isCamera = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostBottomSheet(
        onSourceSelected: (camera) => Navigator.pop(context, camera),
      ),
    );

    if (isCamera != null) {
      final picker = ImagePicker();
      final source = isCamera ? ImageSource.camera : ImageSource.gallery;
      try {
        final image = await picker.pickImage(source: source);
        if (image != null && mounted) {
          setState(() {
            _images.add(image.path);
            _selectedImageIndex = _images.length - 1;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao selecionar imagem')),
          );
        }
      }
    }
  }

  void _showSelectMission() {
    showDialog(
      context: context,
      builder: (context) => SelectMissionDialog(
        missions: _missions,
        selectedMission: _selectedMission,
        onConfirm: (mission) {
          setState(() => _selectedMission = mission);
        },
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_selectedImageIndex >= _images.length) {
        _selectedImageIndex = _images.length - 1;
      }
    });
    if (_images.isEmpty) {
      Navigator.pop(context);
    }
  }

  Future<void> _savePost() async {
    if (_images.isEmpty) return;

    setState(() => _isSharing = true);

    final repo = getIt<FeedRepository>();
    final result = _isEditing
        ? await repo.updatePost(
            postId: widget.postToEdit!.id,
            images: _images,
            caption: _captionController.text,
            missionId: _selectedMission?.id,
            privado: _isPrivate,
          )
        : await repo.createPost(
            imagePaths: _images,
            caption: _captionController.text,
            missionId: _selectedMission?.id,
            privado: _isPrivate,
          );

    if (!mounted) return;

    result.fold(
      (e) {
        setState(() => _isSharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${_isEditing ? 'salvar' : 'publicar'}: $e'),
          ),
        );
      },
      (success) {
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper to build image provider based on path type
    ImageProvider getImageProvider(String path) {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      } else {
        return FileImage(File(path));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: _isEditing ? 'Editar post' : 'Novo post',
        subtitle: _isEditing
            ? 'Edite sua publicação'
            : 'Crie uma nova publicação',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Image View
                  if (_images.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: getImageProvider(
                              _images[_selectedImageIndex],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(_selectedImageIndex),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Excluir',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  // Carousel
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedImageIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = index),
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          )
                                        : null,
                                    image: DecorationImage(
                                      image: getImageProvider(_images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addMoreImages,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),

                  // Selection list
                  _buildListTile(
                    customLeading: _selectedMission?.logo != null
                        ? Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(_selectedMission!.logo!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : null,
                    icon: Icons.search,
                    title: _selectedMission?.name ?? 'Selecionar missão',
                    onTap: _showSelectMission,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'Privar para missão',
                    subtitle:
                        'Apenas viajantes da missão selecionada podem visualizar sua publicação.',
                    trailing: Switch(
                      value: _isPrivate,
                      onChanged: _selectedMission == null
                          ? null
                          : (v) => setState(() => _isPrivate = v),
                      activeColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Caption Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _captionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Adicione uma legenda',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: AppSpacing.xl,
            ),
            child: ElevatedButton(
              onPressed: _isSharing ? null : _savePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSharing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isEditing ? 'Salvar Alterações' : 'Compartilhar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.ios_share,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    Widget? customLeading,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (customLeading != null)
              customLeading
            else if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
