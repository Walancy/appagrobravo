import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

/// Tipo de documento a ser exibido no preview.
enum _PreviewType { pdf, image, unknown }

/// Página de preview in-app para documentos PDF e imagens.
///
/// Suporta arquivos locais (via [filePath]) e remotos (via [url]).
/// Detecta automaticamente o tipo pelo path/extensão.
///
/// Exemplo de uso:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DocumentPreviewPage(
///     url: 'https://example.com/doc.pdf',
///     title: 'Passaporte',
///   ),
/// ));
/// ```
class DocumentPreviewPage extends StatefulWidget {
  /// URL remota do documento (PDF ou imagem).
  final String? url;

  /// Caminho local do arquivo (PDF ou imagem).
  final String? filePath;

  /// Título exibido na AppBar.
  final String title;

  const DocumentPreviewPage({
    super.key,
    this.url,
    this.filePath,
    required this.title,
  }) : assert(url != null || filePath != null,
            'Pelo menos url ou filePath deve ser informado.');

  @override
  State<DocumentPreviewPage> createState() => _DocumentPreviewPageState();

  /// Método estático para navegar rapidamente para o preview.
  static void show(
    BuildContext context, {
    String? url,
    String? filePath,
    required String title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentPreviewPage(
          url: url,
          filePath: filePath,
          title: title,
        ),
      ),
    );
  }
}

class _DocumentPreviewPageState extends State<DocumentPreviewPage>
    with SingleTickerProviderStateMixin {
  _PreviewType _type = _PreviewType.unknown;
  bool _isLoading = true;
  String? _errorMessage;

  // PDF state
  PdfControllerPinch? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

  // Image state (for local files)
  File? _localImageFile;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _detectAndLoad();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Determina o tipo de arquivo e carrega o conteúdo.
  Future<void> _detectAndLoad() async {
    final source = widget.filePath ?? widget.url ?? '';
    final lower = source.toLowerCase();

    // Detectar tipo
    if (lower.endsWith('.pdf') ||
        lower.contains('/pdf') ||
        lower.contains('application/pdf')) {
      _type = _PreviewType.pdf;
    } else if (_isImageExtension(lower)) {
      _type = _PreviewType.image;
    } else {
      // Tentar detectar pelo content-type para URLs
      if (widget.url != null) {
        _type = await _detectTypeFromUrl(widget.url!);
      }
    }

    if (_type == _PreviewType.unknown) {
      // Fallback: tenta como imagem
      _type = _PreviewType.image;
    }

    try {
      if (_type == _PreviewType.pdf) {
        await _loadPdf();
      } else {
        await _loadImage();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Não foi possível carregar o documento: $e';
        });
      }
    }
  }

  bool _isImageExtension(String path) {
    return ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp']
        .any((ext) => path.endsWith(ext));
  }

  Future<_PreviewType> _detectTypeFromUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('pdf')) return _PreviewType.pdf;
      if (contentType.contains('image')) return _PreviewType.image;
    } catch (_) {}
    return _PreviewType.unknown;
  }

  /// Carrega o PDF (local ou remoto).
  Future<void> _loadPdf() async {
    PdfDocument document;

    if (widget.filePath != null) {
      // PDF local
      document = await PdfDocument.openFile(widget.filePath!);
    } else {
      // PDF remoto — baixar para temp
      final tempPath = await _downloadToTemp(widget.url!, 'preview.pdf');
      document = await PdfDocument.openFile(tempPath);
    }

    if (!mounted) return;

    setState(() {
      _totalPages = document.pagesCount;
      _pdfController = PdfControllerPinch(
        document: Future.value(document),
      );
      _isLoading = false;
    });
    _fadeController.forward();
  }

  /// Carrega a imagem (local ou remota).
  Future<void> _loadImage() async {
    if (widget.filePath != null) {
      _localImageFile = File(widget.filePath!);
    }
    // Para imagens remotas, CachedNetworkImage cuida do carregamento.

    if (!mounted) return;
    setState(() => _isLoading = false);
    _fadeController.forward();
  }

  /// Baixa um arquivo remoto para o diretório temporário.
  Future<String> _downloadToTemp(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Erro ao baixar arquivo: ${response.statusCode}');
    }

    final tempDir = await getTemporaryDirectory();
    final ext = _getExtension(url);
    final file = File(
      '${tempDir.path}/doc_preview_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  String _getExtension(String path) {
    final uri = Uri.tryParse(path);
    final p = uri?.path ?? path;
    final dot = p.lastIndexOf('.');
    if (dot != -1) return p.substring(dot);
    return '.pdf';
  }

  /// Abre o documento no app externo (fallback).
  Future<void> _openExternally() async {
    final urlStr = widget.url ?? widget.filePath;
    if (urlStr == null) return;

    Uri? uri;
    if (widget.filePath != null) {
      uri = Uri.file(widget.filePath!);
    } else {
      uri = Uri.tryParse(urlStr);
    }

    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_type == _PreviewType.pdf && _totalPages > 0)
              Text(
                'PDF • $_totalPages página${_totalPages > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          // Botão abrir externamente
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Abrir externamente',
            onPressed: _openExternally,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      // Barra inferior com indicador de página (somente para PDF)
      bottomNavigationBar: _type == _PreviewType.pdf && _totalPages > 1
          ? _buildPageIndicator()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_type == _PreviewType.pdf) {
      return _buildPdfViewer();
    }

    return _buildImageViewer();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _type == _PreviewType.pdf
                ? 'Carregando documento...'
                : 'Carregando...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Erro ao carregar',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erro desconhecido',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Abrir externamente'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_pdfController == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PdfViewPinch(
        controller: _pdfController!,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          errorBuilder: (_, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Erro ao renderizar PDF',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: _localImageFile != null
              ? Image.file(
                  _localImageFile!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, error, __) => _buildImageError(),
                )
              : CachedNetworkImage(
                  imageUrl: widget.url!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  errorWidget: (_, __, ___) => _buildImageError(),
                ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
        const SizedBox(height: 12),
        Text(
          'Não foi possível carregar a imagem',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Página $_currentPage de $_totalPages',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
