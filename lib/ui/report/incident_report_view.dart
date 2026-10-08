import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:podd_app/components/playable_file_view.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/report/full_screen_view.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import 'package:podd_app/ui/report/report_comment_view.dart';
import 'package:podd_app/ui/report/followup_list_view.dart';
import 'package:stacked/stacked.dart';

final _timestampFormatter = DateFormat('dd/MM/yy HH:mm');
final _dateFormatter = DateFormat('dd/MM/yy');
Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandDeep => OhtkTheme.palette.teal900;
Color get _brandTint => OhtkTheme.palette.teal700.withValues(alpha: 0.08);

class IncidentReportView extends HookWidget {
  final String id;

  const IncidentReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IncidentReportViewModel>.reactive(
      viewModelBuilder: () => IncidentReportViewModel(id),
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: viewModel.mapRenderedComplete,
          child: Scaffold(
            backgroundColor: incidentsSand,
            appBar: const _DetailAppBar(),
            body: _DetailBody(viewModel: viewModel),
          ),
        );
      },
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: _brandDeep,
      padding: EdgeInsets.only(top: topInset),
      height: 60 + topInset,
      child: Stack(
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)?.reportDetailTitle ??
                  'Report detail',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends HookWidget {
  final IncidentReportViewModel viewModel;

  const _DetailBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isBusy) {
      return const _LoadingState();
    }
    if (viewModel.hasError || viewModel.data == null) {
      return const _ErrorState();
    }

    final incident = viewModel.data!;
    final tabController = useTabController(initialLength: 3);
    final activeTab = useState(0);

    useEffect(() {
      void listener() => activeTab.value = tabController.index;
      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    final canFollowup = incident.reportTypeFollowable && !incident.testFlag;
    final showFab =
        canFollowup && (activeTab.value == 0 || activeTab.value == 2);

    final localize = AppLocalizations.of(context)!;
    final labels = [
      localize.detailTabLabel,
      localize.commentTabLabel,
      localize.followupTabLabel,
    ];

    return Column(
      children: [
        _TabStrip(
          controller: tabController,
          activeIndex: activeTab.value,
          labels: labels,
        ),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: tabController,
                children: [
                  _DetailTab(incident: incident, viewModel: viewModel),
                  ReportCommentView(incident.threadId!),
                  FollowupListView(incident.id),
                ],
              ),
              if (showFab)
                Positioned(
                  right: 16,
                  bottom: 22 + MediaQuery.of(context).padding.bottom,
                  child: _FollowUpFab(
                    extended: activeTab.value == 0,
                    onPressed: () {
                      GoRouter.of(context).goNamed(
                        OhtkRouter.followupReportForm,
                        pathParameters: {
                          'reportTypeId': incident.reportTypeId,
                          'incidentId': incident.id,
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabStrip extends StatelessWidget {
  final TabController controller;
  final int activeIndex;
  final List<String> labels;

  const _TabStrip({
    required this.controller,
    required this.activeIndex,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: incidentsHair)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => controller.animateTo(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: activeIndex == i
                            ? _brandPrimary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: activeIndex == i ? incidentsInk : incidentsMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailTab extends StatelessWidget {
  final IncidentReport incident;
  final IncidentReportViewModel viewModel;

  const _DetailTab({required this.incident, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      _HeaderBlock(incident: incident),
      _DescriptionBlock(incident: incident),
      if (incident.hasAccumulatedMetrics)
        _AccumulatedMetricsBlock(incident: incident),
      _MetaBlock(incident: incident),
      if ((incident.images ?? []).isNotEmpty) _PhotosBlock(incident: incident),
      if ((incident.files ?? []).isNotEmpty)
        _AttachmentsBlock(incident: incident),
      _LocationBlock(viewModel: viewModel),
    ];

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
          itemCount: blocks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => blocks[i],
        ),
        if (incident.testFlag)
          const Positioned.fill(
            child: IgnorePointer(child: _TestWatermark()),
          ),
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String? eyebrow;
  final Widget child;
  final EdgeInsets padding;

  const _DetailBlock({
    this.eyebrow,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsHair),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                eyebrow!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: incidentsInk,
                ),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  final IncidentReport incident;

  const _HeaderBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final hasPills = incident.caseId != null || incident.testFlag;
    return _DetailBlock(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              incident.reportTypeName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: incidentsInk,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _timestampFormatter.format(incident.createdAt.toLocal()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: incidentsMuted,
                ),
              ),
              if (hasPills) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    if (incident.caseId != null)
                      _StatusPill(
                        label: localize.caseTag,
                        bg: incidentsCasePillBg,
                        fg: incidentsCasePillFg,
                      ),
                    if (incident.testFlag)
                      _StatusPill(
                        label: localize.testTag,
                        bg: incidentsTestPillBg,
                        fg: incidentsTestPillFg,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusPill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final IncidentReport incident;

  const _DescriptionBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final hasBody = incident.description.trim().isNotEmpty;
    return _DetailBlock(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Text(
        hasBody
            ? incident.trimWhitespaceDescription
            : localize.noDescriptionProvided,
        style: TextStyle(
          fontSize: 15,
          height: 1.55,
          color: hasBody ? incidentsBody : incidentsMuted,
        ),
      ),
    );
  }
}

class _AccumulatedMetricsBlock extends StatelessWidget {
  final IncidentReport incident;

  const _AccumulatedMetricsBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final metrics = incident.accumulatedMetrics ?? const [];
    return _DetailBlock(
      eyebrow: 'Totals (report + follow-ups)',
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        children: [
          for (final metric in metrics) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: incidentsBody,
                    ),
                  ),
                ),
                Text(
                  '${metric.value}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: incidentsInk,
                  ),
                ),
              ],
            ),
            if (metric != metrics.last)
              const Divider(height: 16, color: incidentsHair),
          ],
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  final IncidentReport incident;

  const _MetaBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsHair),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MetaCell(
                label: localize.authorityLabel,
                value: (incident.authorityName != null &&
                        incident.authorityName!.isNotEmpty)
                    ? incident.authorityName!
                    : '-',
              ),
            ),
            const VerticalDivider(width: 1, color: incidentsHair),
            Expanded(
              child: _MetaCell(
                label: localize.incidentDate,
                value: _dateFormatter.format(incident.incidentDate.toLocal()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  final String label;
  final String value;

  const _MetaCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: incidentsMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: incidentsInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosBlock extends StatelessWidget {
  final IncidentReport incident;

  const _PhotosBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final images = incident.images ?? [];
    return _DetailBlock(
      eyebrow: '${localize.photosSectionLabel}  ·  ${images.length}',
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final image = images[i];
            return FullScreenWidget(
              fullscreenChild: CachedNetworkImage(
                cacheKey: image.id,
                imageUrl: image.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 132,
                  height: 132,
                  child: CachedNetworkImage(
                    cacheKey: 'thumbnail-${image.id}',
                    imageUrl: image.thumbnailPath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: incidentsHair),
                    errorWidget: (context, url, error) => Container(
                      color: incidentsHair,
                      child: const Icon(Icons.error, color: incidentsMuted),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AttachmentsBlock extends StatelessWidget {
  final IncidentReport incident;

  const _AttachmentsBlock({required this.incident});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final files = incident.files ?? [];
    return _DetailBlock(
      eyebrow: '${localize.attachmentsSectionLabel}  ·  ${files.length}',
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < files.length; i++)
            _AttachmentRow(
              file: files[i],
              isFirst: i == 0,
            ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final IncidentReportFile file;
  final bool isFirst;

  const _AttachmentRow({required this.file, required this.isFirst});

  Future<void> _open(BuildContext context) async {
    if (file.fileType.contains('audio')) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.white.withValues(alpha: 0),
          pageBuilder: (BuildContext context, _, __) {
            return PlayableReportFileView(
              type: file.fileType,
              url: file.fileUrl,
            );
          },
        ),
      );
      return;
    }
    final filePath = await _downloadFile(file.fileUrl, file.filePath);
    if (filePath == null) return;
    if (!context.mounted) return;
    final result = await OpenFile.open(filePath, type: file.fileType);
    if (context.mounted && result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: incidentsErrorRed,
        content: Text(
          'Cannot open file.\nEither no app supports or file is corrupted',
        ),
        duration: Duration(milliseconds: 3000),
      ));
    }
  }

  Future<String?> _downloadFile(String url, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final cachePath = '${tempDir.path}/$fileName';
    if (File(cachePath).existsSync()) return cachePath;
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final f = await File(cachePath).create(recursive: true);
        await f.writeAsBytes(bytes);
        return cachePath;
      }
    } catch (ex) {
      Logger().e('Error downloading file: $ex');
    }
    return null;
  }

  IconData _iconFor(String mimeType) {
    if (mimeType.contains('audio')) return Icons.audiotrack_outlined;
    if (mimeType.contains('video')) return Icons.video_file_outlined;
    if (mimeType.contains('image')) return Icons.image_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isFirst ? Colors.transparent : incidentsHair,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _brandTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                _iconFor(file.fileType),
                size: 20,
                color: _brandPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file.filePath.split('/').last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: incidentsInk,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.file_download_outlined,
              size: 18,
              color: _brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  final IncidentReportViewModel viewModel;

  const _LocationBlock({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final latlng = viewModel.latlng;

    if (latlng == null) {
      return _DetailBlock(
        eyebrow: localize.locationSectionLabel,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Text(
          localize.noGpsProvided,
          style: const TextStyle(
            fontSize: 13,
            color: incidentsMuted,
          ),
        ),
      );
    }

    return _DetailBlock(
      eyebrow: localize.locationSectionLabel,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: _MapView(
              latlng: latlng,
              onRendered: () => viewModel.mapRenderedComplete = true,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: incidentsHair)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: _brandPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${latlng[0].toStringAsFixed(4)}° · ${latlng[1].toStringAsFixed(4)}°',
                    style: const TextStyle(
                      fontSize: 12,
                      color: incidentsBody,
                    ),
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

class _MapView extends StatelessWidget {
  final List<double> latlng;
  final VoidCallback onRendered;

  const _MapView({required this.latlng, required this.onRendered});

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('center'),
      position: LatLng(latlng[0], latlng[1]),
    );
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        zoom: 12,
        target: LatLng(latlng[0], latlng[1]),
      ),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      scrollGesturesEnabled: true,
      onMapCreated: (_) => onRendered(),
      markers: {marker},
    );
  }
}

class _TestWatermark extends StatelessWidget {
  const _TestWatermark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.3839, // -22 degrees in radians
        child: Text(
          'TEST · TEST · TEST',
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            letterSpacing: 8,
            color: incidentsInk.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}

class _FollowUpFab extends StatelessWidget {
  final bool extended;
  final VoidCallback onPressed;

  const _FollowUpFab({required this.extended, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)?.followUpFabLabel ?? 'Follow up';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: extended
              ? const EdgeInsets.fromLTRB(16, 0, 18, 0)
              : EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 56,
            maxWidth: extended ? double.infinity : 56,
          ),
          decoration: BoxDecoration(
            color: _brandPrimary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38000000),
                offset: Offset(0, 6),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 24),
              if (extended) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context);
    return Container(
      color: incidentsSand,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(_brandPrimary),
              backgroundColor: incidentsHair,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localize?.loadingLabel ?? 'Loading…',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: incidentsMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context);
    return Container(
      color: incidentsSand,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: incidentsErrorTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: incidentsErrorRed,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            localize?.reportNotFoundTitle ?? 'Report not found',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: incidentsInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localize?.reportNotFoundHelper ??
                'This report may have been removed, or you might be offline.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: incidentsMuted,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: _brandPrimary,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => GoRouter.of(context).go('/reports'),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  localize?.backToIncidentsButton ?? 'Back to incidents',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
