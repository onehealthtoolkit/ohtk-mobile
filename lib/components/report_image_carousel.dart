import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/base_report_image.dart';
import 'package:podd_app/ui/report/full_screen_view.dart';

class ReportImagesCarousel<T extends BaseReportImage> extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final List<T>? images;

  ReportImagesCarousel(
    this.images, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageWidgets = images?.map((image) => Container(
          margin: const EdgeInsets.all(0),
          child: ReportImageDisplay(image),
        ));

    return Container(
      color: images != null && images!.isNotEmpty ? appTheme.bg1 : null,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 200),
      child: SizedBox(
        height: 240,
        child: (images != null && images!.isNotEmpty)
            ? CarouselSlider(
                items: imageWidgets?.toList() ?? [],
                options: CarouselOptions(
                  height: 240,
                  enlargeCenterPage: true,
                  aspectRatio: 1,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  disableCenter: true,
                  enableInfiniteScroll: false,
                ),
              )
            : ColoredBox(
                color: appTheme.sub4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Images",
                        style: TextStyle(
                          color: appTheme.sub2,
                          fontSize: 16.sp,
                        ),
                      ),
                      Image.asset(
                        "assets/images/OHTK.png",
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class ReportImageDisplay<T extends BaseReportImage> extends StatelessWidget {
  final T image;

  const ReportImageDisplay(
    this.image, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FullScreenWidget(
      fullscreenChild: CachedNetworkImage(
        imageUrl: image.imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      child: CachedNetworkImage(
        imageUrl: image.thumbnailPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
