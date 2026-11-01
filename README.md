# Cours+ — prototype Flutter
Application de cours primaire, collège et lycée, quiz corrigés, progression locale et abonnement Premium **simulé** à 19,99 €/mois.

## Développement local
Installer Flutter puis :
```bash
flutter create --platforms=android,windows,web .
flutter pub get
flutter run -d chrome
```

## Builds automatiques
Ouvrir **Actions → Build Cours+ → Run workflow**. Les fichiers générés sont téléchargeables dans les **Artifacts** du workflow : APK Android, dossier Windows, site Web statique. Les builds ne sont pas des publications sur Play Store/Microsoft Store ni un hébergement web.

## Limites
Prototype avec 11 leçons d'exemple. Pas de paiement réel, authentification, backend, IA ni CMS. Premium est uniquement un interrupteur local de démonstration. Avant commercialisation, intégrer un prestataire de paiement et une validation sécurisée des droits, ainsi que les exigences de chaque boutique et du RGPD.
