import 'package:flutter/material.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
        viewModelBuilder: () => HomeViewModel(),
        builder: (context, viewModel, child) => Scaffold(
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
            ));
  }
}
