part of 'widgets.dart';

class FormQuestion extends StatelessWidget {
  final opsv.Question question;
  final AppTheme apptheme = locator<AppTheme>();

  FormQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppTheme apptheme = locator<AppTheme>();

    return Observer(
      builder: (BuildContext context) {
        if (!question.display) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            shadowColor: Colors.transparent,
            child: Container(
              color: apptheme.bg2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: apptheme.warn,
                            fontSize: 14.sp,
                          ),
                    ),
                    if (question.description != null &&
                        question.description!.isNotEmpty) ...[
                      Text(
                        question.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: apptheme.sub1,
                            ),
                      ),
                      SizedBox(height: 5.h)
                    ],
                    ListView.separated(
                      itemBuilder: (context, index) {
                        return FormField(field: question.fields[index]);
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: question.fields.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
