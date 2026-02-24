# Cosmetics Expansion Guide

This app currently supports one equipped cosmetic at a time (frame/style), purchased with coins.

## Fast Path: add a new cosmetic in 1 file

1. Open `lib/domain/cosmetic_catalog.dart`.
2. Add a new `CosmeticDefinition`.
3. Add it to `CosmeticCatalog.all`.

The Shop will auto-list it, purchase/equip will work, and a fallback color/icon is generated automatically.

## Optional: give your cosmetic a custom look

If you want intentional visuals instead of generated fallback:

1. Open `lib/ui/theme/cosmetic_visuals.dart`.
2. Add your cosmetic ID to `_knownCosmeticVisuals` with a specific color and icon.

## Good places to add more cosmetics next

1. Dashboard progression card frame: already implemented.
2. Skill tree node ring styles: tint unlocked/progressed nodes by equipped style.
3. Movement detail header skin: themed border/gradient around mastery card.
4. Badge card accents: cosmetic tint on earned badge cards.
5. Quick log sheet chrome: cosmetic color in header and save button.
6. App shell profile chip: small icon + color showing currently equipped style.

## If you want to make your own art assets

Current implementation is vector/icon based. If you want image-based skins:

1. Add an optional asset path field to `CosmeticDefinition`.
2. Add asset files under something like `assets/cosmetics/`.
3. Register that folder in `pubspec.yaml`.
4. Render asset previews in `lib/ui/screens/shop_screen.dart`.
5. Apply the asset as an overlay/background in `lib/ui/screens/dashboard_screen.dart`.

This is the cleanest route to fully custom, hand-made cosmetics.
