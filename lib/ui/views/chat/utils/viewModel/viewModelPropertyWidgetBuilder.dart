
import 'package:flutter/widgets.dart';
import 'package:lipa_quick/ui/views/chat/utils/viewModel/viewModel.dart';

class ViewModelPropertyWidgetBuilder<TPropertyType>
    extends StreamBuilder<PropertyChangedEvent> {

  ViewModelPropertyWidgetBuilder(
      {Key? key,
      required ViewModel viewModel,
      required String propertyName,
      required AsyncWidgetBuilder<PropertyChangedEvent> builder})
      : super(
            key: key,
            builder: builder,
            stream: viewModel.whenPropertyChanged(propertyName));
}
