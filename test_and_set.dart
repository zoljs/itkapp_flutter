// ignore_for_file: avoid_print

bool handling = false;
int logouts = 0;

// Helyes: az ellenőrzés és a foglalás között nincs await.
Future<void> safeLogout() async {
  if (handling) return;
  handling = true;
  try {
    logouts++;
    await Future.delayed(const Duration(milliseconds: 100));
  } finally {
    handling = false;
  }
}

// Hibás: közbeékelt await, a többi hívás is szabadnak látja a zárat.
Future<void> unsafeLogout() async {
  if (handling) return;
  await Future.delayed(Duration.zero);
  handling = true;
  try {
    logouts++;
    await Future.delayed(const Duration(milliseconds: 100));
  } finally {
    handling = false;
  }
}

Future<void> main() async {
  await Future.wait([safeLogout(), safeLogout(), safeLogout()]);
  print('Helyes: $logouts kijelentkezés');

  logouts = 0;
  await Future.wait([unsafeLogout(), unsafeLogout(), unsafeLogout()]);
  print('Hibás: $logouts kijelentkezés');
}
