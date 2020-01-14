///🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️
/// Global .chain((in)=>out)
///
/// I = Input Type
/// O = output Type
///
/// Usage:
///  "test"
///    .chain((val)=>val.length)      -> 4
///    .chain((val)=>val*val)         -> 16
///
/// Just like you'd map in a collection
///
/// Useful for scoping a value without
/// creating a variable.
extension ChainHelper<IN, OUT> on IN {
  /// Chain values togeter
  OUT chain<OUT>(OUT mapFunc(IN input)) => mapFunc(this);
}
