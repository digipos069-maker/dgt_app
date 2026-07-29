import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/resource_document_model.dart';

class ResourceVideoViewer extends StatefulWidget {
  const ResourceVideoViewer({required this.document, super.key});

  final ResourceDocumentModel document;

  @override
  State<ResourceVideoViewer> createState() => _ResourceVideoViewerState();
}

class _ResourceVideoViewerState extends State<ResourceVideoViewer> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _hasError = false);
    final previousController = _controller;
    _controller = null;
    await previousController?.dispose();

    final uri = Uri.tryParse(widget.document.sourceUrl);
    if (uri == null || !uri.hasScheme) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() {});
    } on Object {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _controller = null;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Future<void> _toggleVolume() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setVolume(controller.value.volume == 0 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF11151C),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: _buildVideoSurface(context)),
          if (_controller?.value.isInitialized == true)
            _VideoControls(
              controller: _controller!,
              onTogglePlayback: _togglePlayback,
              onToggleVolume: _toggleVolume,
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSurface(BuildContext context) {
    final controller = _controller;
    if (controller?.value.isInitialized == true) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    }

    if (_hasError) {
      return _VideoError(onRetry: _initialize);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.onTogglePlayback,
    required this.onToggleVolume,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlayback;
  final VoidCallback onToggleVolume;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacing12,
            AppSizes.spacing8,
            AppSizes.spacing12,
            AppSizes.spacing12,
          ),
          child: Column(
            children: [
              VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              Row(
                children: [
                  IconButton(
                    onPressed: onTogglePlayback,
                    color: Colors.white,
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  Text(
                    '${_formatDuration(value.position)} / '
                    '${_formatDuration(value.duration)}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleVolume,
                    color: Colors.white,
                    icon: Icon(
                      value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              context.l10n.text('resourceVideoLoadFailed'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSizes.spacing12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
