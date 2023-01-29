part of 'widgets.dart';

class FormQuestion extends StatelessWidget {
  final opsv.Question question;

  const FormQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        if (!question.display) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.label,
                    textScaleFactor: 1.2,
                  ),
                  const SizedBox(height: 10),
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
        );
      },
    );
  }
}
