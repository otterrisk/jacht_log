l10n_inp = $(wildcard lib/l10n/*.arb)
l10n_out = lib/l10n/app_localizations.dart

l10n: $(l10n_out)

$(l10n_out): $(l10n_inp)
	flutter gen-l10n

.PHONY: l10n