SERVER_LIST_ENDPOINT="${SERVER_LIST_ENDPOINT:-https://api.lahis.ohtk.org/api/servers/}"

flutter build appbundle --release \
  --dart-define=TENANT_API_ENDPOINT="${SERVER_LIST_ENDPOINT}"
flutter build ipa --release \
  --dart-define=TENANT_API_ENDPOINT="${SERVER_LIST_ENDPOINT}"
