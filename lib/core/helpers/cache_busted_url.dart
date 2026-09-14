/// Appends a `version` query param to a URL so [Image.network] (which
/// caches by URL string) always re-fetches after the underlying file
/// changes — needed for any user-uploaded image (avatar, logo, ...) whose
/// backend URL stays the same string across re-uploads. The caller owns
/// picking `version` (e.g. a timestamp stored once in state when the image
/// actually changes) so the busted URL stays stable across unrelated
/// rebuilds instead of changing — and re-fetching — on every build.
String cacheBustedUrl(String url, {required int version}) {
  final separator = url.contains('?') ? '&' : '?';
  return '$url${separator}_cb=$version';
}
