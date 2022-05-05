import 'package:flutter/material.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportTypeView(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hello ${viewModel.username}"),
              TextButton(
                onPressed: () {
                  viewModel.logout();
                },
                child: const Text("logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
