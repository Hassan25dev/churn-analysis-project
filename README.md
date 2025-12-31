# 📉 Projet “Churn des abonnés” – Analyse Multi-Sources

> **Fusion de données SQL, CSV et MongoDB pour prédire et comprendre le désabonnement client**  
> Réalisé dans le cadre du Bootcamp **« Data Analyst augmenté·e par l’IA »** – **JobInTech**

![License](https://img.shields.io/badge/License-MIT-blue.svg)

---

## 🎯 Objectifs métier

- Calculer le **taux de churn global**
- Analyser la **satisfaction client** (support + avis) selon le statut (`actif` / `désabonné`)
- Mesurer la **fréquence d’activité** (connexions, appareils)
- Évaluer la **corrélation entre retards de paiement et désabonnement**

> 🔍 Résultat clé : **corrélation de +0.67** → les retards de paiement sont fortement associés au churn.

---

## 🗃️ Sources de données intégrées

| Source      | Contenu                          | Fichier |
|-------------|----------------------------------|---------|
| **SQL**     | Clients, Paiements, Support      | [`sql/churn_analysis_script.sql`](./sql/churn_analysis_script.sql) |
| **CSV**     | Avis de satisfaction (25 clients)| [`data/Avis.csv`](./data/Avis%20(1).csv) |
| **MongoDB** | Logs d’activité (connexions)     | [`docs/mongodb_insertion.js`](./docs/mongodb_insertion.js) |

> 💡 Le projet est **autonome en SQL** : les données externes sont simulées dans le script pour faciliter l’exécution.

🧠 Les logs MongoDB illustrent une source NoSQL typique utilisée pour l’analyse comportementale et l’enrichissement des indicateurs d’activité.

---

## 🧩 Structure du projet

churn-analysis-project/

├── README.md

├── LICENSE

├── data/

│  └── Avis.csv

├── sql/

│  └── churn_analysis_script.sql

└── docs/

   └── mongodb_insertion.js


---


## 📊 Indicateurs clés

| Indicateur | Valeur |
|-----------|--------|
| Taux de churn global | **33.33%** |
| Satisfaction moyenne (avis) – Actifs | **48/50** |
| Satisfaction moyenne (avis) – Désabonnés | **31/50** |
| Fréquence moyenne d’activité | **1.67 connexions/client** |
| Corrélation (Pearson) : retards ↔ churn | **+0.67** |

---

## ▶️ Comment exécuter

1. Créer une base de données nommée churnDb
2. Exécute le script :  
   
   ```SOURCE sql/churn_analysis_script.sql;```
   
3. Interroge la vue consolidée :

   ``` SELECT * FROM Consolidation_Churn;```


💻 Compatible avec MySQL, SQL Server (modifications mineures pour GO + DATEDIFF), ou MariaDB.

---


📌 Prochaines améliorations


Modélisation prédictive du churn

Visualisation (Power BI ou Python)

Automatisation du pipeline de données

---

📝 À propos

Auteur : HASSANE AMANAD

Contexte : Bootcamp Data Analyst augmenté·e par l’IA – JobInTech (en partenariat avec Groupe Holmarcom & AI Institute)

Compétences démontrées :

Intégration multi-sources (SQL + CSV + NoSQL)

Conception de KPIs métier

Analyse statistique (corrélation de Pearson)

Documentation technique claire

Licence : MIT

GitHub : @Hassan25dev

