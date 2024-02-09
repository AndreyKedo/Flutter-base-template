import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<Object?> dropEventTransformer() =>
    (Stream<Object?> events, EventMapper<Object?> mapper) => events.exhaustMap<Object?>(mapper);

EventTransformer<Event> debounceSequential<Event>(Duration duration) {
  return (events, mapper) {
    return events.debounceTime(duration).switchMap(mapper);
  };
}
