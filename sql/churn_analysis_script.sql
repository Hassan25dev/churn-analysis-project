-- =========================================================
-- 📊 BASE DE DONNÉES : churnDb
-- Objectif : Analyser le churn (désabonnement) client
-- à partir des données clients, paiements, support, satisfaction et activité.
-- =========================================================

USE churnDb;
GO

-- =========================================================
-- 🧱 1️⃣ TABLE CLIENTS : Informations de base
-- =========================================================
CREATE TABLE Clients (
    id_client INT PRIMARY KEY,      -- Identifiant unique du client
    nom NVARCHAR(50),               -- Nom complet
    email NVARCHAR(100),            -- Adresse email
    date_inscription DATE,          -- Date d’inscription
    statut NVARCHAR(20)             -- Statut : 'actif' ou 'désabonné'
);
GO

-- =========================================================
-- 💰 2️⃣ TABLE PAIEMENTS : Historique financier
-- =========================================================
CREATE TABLE Paiements (
    id_paiement INT PRIMARY KEY,
    id_client INT FOREIGN KEY REFERENCES Clients(id_client),
    montant DECIMAL(10,2),           -- Montant du paiement
    date_paiement DATE,              -- Date du paiement
    statut NVARCHAR(20)              -- 'payé' ou 'en retard'
);
GO

-- =========================================================
-- 🎧 3️⃣ TABLE SUPPORT CLIENT : Tickets et satisfaction
-- =========================================================
CREATE TABLE SupportClient (
    id_ticket INT PRIMARY KEY,
    id_client INT FOREIGN KEY REFERENCES Clients(id_client),
    sujet NVARCHAR(100),             -- Sujet du ticket
    delai_resolution INT,            -- Temps de résolution (heures)
    satisfaction INT                 -- Note sur 5
);
GO

-- =========================================================
-- 📥 4️⃣ INSERTION DE DONNÉES EXEMPLES
-- =========================================================
INSERT INTO Clients VALUES
(1, 'Sara Haddad', 'sara@exemple.com', '2024-01-12', 'actif'),
(2, 'Youssef Idrissi', 'youssef@exemple.com', '2023-11-05', 'désabonné'),
(3, 'Amine Belkadi', 'amine@exemple.com', '2024-02-01', 'actif');

INSERT INTO Paiements VALUES
(101, 1, 300, '2024-10-10', 'payé'),
(102, 1, 300, '2024-11-10', 'payé'),
(103, 2, 200, '2024-09-12', 'en retard'),
(104, 3, 300, '2024-10-01', 'payé');

INSERT INTO SupportClient VALUES
(201, 1, 'Problème de connexion', 12, 4),
(202, 2, 'Annulation abonnement', 24, 2),
(203, 3, 'Changement moyen de paiement', 6, 5);
GO

-- =========================================================
-- 🧩 5️⃣ VUE CONSOLIDÉE : Consolidation_Churn
-- Vue globale de tous les indicateurs clients
-- =========================================================
CREATE VIEW Consolidation_Churn AS
SELECT
    c.id_client,
    c.nom,
    c.statut,
    c.date_inscription,
    DATEDIFF(DAY, c.date_inscription, GETDATE()) AS anciennete_jours, -- Ancienneté client en jours
    lc.freq_connexion,       -- Fréquence de connexion (activité)
    lc.dernier_device,       -- Dernier appareil utilisé
    ac.score_satisfaction,   -- Note moyenne des avis
    COUNT(p.id_paiement) AS nb_paiements_total,                        -- Nombre total de paiements
    SUM(CASE WHEN p.statut = 'en retard' THEN 1 ELSE 0 END) AS nb_paiements_en_retard, -- Retards
    AVG(p.montant) AS montant_moyen_paiement,                          -- Montant moyen payé
    AVG(sc.satisfaction) AS satisfaction_support_moyenne               -- Moyenne des notes support
FROM Clients c
LEFT JOIN mongo_connexions lc ON c.id_client = lc.id_client
LEFT JOIN avis ac ON c.id_client = ac.id_client
LEFT JOIN Paiements p ON c.id_client = p.id_client
LEFT JOIN SupportClient sc ON c.id_client = sc.id_client
GROUP BY
    c.id_client, c.nom, c.statut, c.date_inscription,
    lc.freq_connexion, lc.dernier_device, ac.score_satisfaction;
GO

-- 🔍 Résultat attendu :
-- id_client | nom              | statut      | anciennete_jours | freq_connexion | dernier_device | score_satisfaction | nb_paiements_total | nb_paiements_en_retard | montant_moyen_paiement | satisfaction_support_moyenne
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1 | Sara Haddad     | actif      | 665 | 2 | desktop | 47 | 2 | 0 | 300.00 | 4
-- 2 | Youssef Idrissi | désabonné  | 733 | 1 | mobile  | 31 | 1 | 1 | 200.00 | 2
-- 3 | Amine Belkadi   | actif      | 645 | 2 | tablet  | 49 | 1 | 0 | 300.00 | 5
SELECT * FROM Consolidation_Churn;
GO

-- =========================================================
-- 📊 6️⃣ ANALYSES DU CHURN
-- =========================================================

-- 🧮 a) Taux de churn global (% de clients désabonnés)
-- Mesure la proportion de clients perdus
SELECT 
    CAST(SUM(CASE WHEN statut = 'désabonné' THEN 1 ELSE 0 END) AS FLOAT) * 100 / COUNT(*) 
    AS taux_churn_global_percent
FROM Clients;
GO
-- ✅ Résultat attendu :
-- taux_churn_global_percent
-- -------------------------
-- 33.33

-- 😊 b-1) Satisfaction du support selon le statut
-- Compare la moyenne des notes de support entre actifs et désabonnés
SELECT 
    c.statut,
    AVG(sc.satisfaction) AS moyenne_satisfaction_support
FROM Clients c
JOIN SupportClient sc ON c.id_client = sc.id_client
GROUP BY c.statut;
GO
-- ✅ Résultat attendu :
-- statut       | moyenne_satisfaction_support
-- actif        | 4
-- désabonné    | 2

-- ⭐ b-2) Satisfaction des avis selon le statut
-- Compare la satisfaction générale (avis) entre actifs et désabonnés
SELECT 
    c.statut,
    AVG(ac.score_satisfaction) AS moyenne_satisfaction_avis
FROM Clients c
JOIN avis ac ON c.id_client = ac.id_client
GROUP BY c.statut;
GO
-- ✅ Résultat attendu :
-- statut       | moyenne_satisfaction_avis
-- actif        | 48
-- désabonné    | 31

-- 📱 c-1) Activité des clients
-- Montre la fréquence et l’appareil d’accès
SELECT 
    c.id_client,
    c.statut,
    lc.freq_connexion AS frequence_activite,
    lc.dernier_device
FROM Clients c
JOIN mongo_connexions lc ON c.id_client = lc.id_client;
GO
-- ✅ Résultat attendu :
-- id_client | statut     | frequence_activite | dernier_device
-- 3 | actif      | 2 | tablet
-- 1 | actif      | 2 | desktop
-- 2 | désabonné  | 1 | mobile

-- 🔁 c-2) Fréquence moyenne globale
-- Moyenne de l’activité de tous les clients
SELECT 
    AVG(freq_connexion) AS frequence_moyenne_globale
FROM mongo_connexions;
GO
-- ✅ Résultat attendu :
-- frequence_moyenne_globale
-- --------------------------
-- 1

-- 💰 d-1) Retards de paiement par client
-- Nombre de paiements en retard par client
SELECT 
    c.id_client,
    c.nom,
    c.statut,
    COUNT(p.id_paiement) AS nb_paiements_en_retard
FROM Clients c
LEFT JOIN Paiements p ON c.id_client = p.id_client AND p.statut = 'en retard'
GROUP BY c.id_client, c.nom, c.statut
ORDER BY nb_paiements_en_retard DESC;
GO
-- ✅ Résultat attendu :
-- id_client | nom              | statut      | nb_paiements_en_retard
-- 2 | Youssef Idrissi | désabonné  | 1
-- 3 | Amine Belkadi   | actif      | 0
-- 1 | Sara Haddad     | actif      | 0

-- 📉 d-2) Moyenne des retards par statut
-- Compare la moyenne des retards entre statuts
SELECT 
    c.statut,
    AVG(CAST(p_retard.nb_retards AS FLOAT)) AS moyenne_retards
FROM Clients c
LEFT JOIN (
    SELECT id_client, COUNT(*) AS nb_retards
    FROM Paiements
    WHERE statut = 'en retard'
    GROUP BY id_client
) p_retard ON c.id_client = p_retard.id_client
GROUP BY c.statut;
GO
-- ✅ Résultat attendu :
-- statut     | moyenne_retards
-- actif      | NULL
-- désabonné  | 1

-- =========================================================
-- 📈 Corrélation entre retards de paiement et désabonnement
-- Objectif : mesurer la relation entre paiements en retard et churn
-- =========================================================
WITH Data AS (
    SELECT
        c.id_client,
        CAST(CASE WHEN c.statut = 'désabonné' THEN 1 ELSE 0 END AS FLOAT) AS desabonne,
        CAST(COUNT(CASE WHEN p.statut = 'en retard' THEN 1 END) AS FLOAT) AS nb_retards
    FROM Clients c
    LEFT JOIN Paiements p ON c.id_client = p.id_client
    GROUP BY c.id_client, c.statut
),
Stats AS (
    SELECT
        AVG(nb_retards) AS avg_retards,
        AVG(desabonne) AS avg_desabonne,
        STDEV(nb_retards) AS stddev_retards,
        STDEV(desabonne) AS stddev_desabonne
    FROM Data
),
Covariance AS (
    SELECT
        AVG((nb_retards - s.avg_retards) * (desabonne - s.avg_desabonne)) AS covar
    FROM Data CROSS JOIN Stats s
)
SELECT
    CASE 
      WHEN stddev_retards = 0 OR stddev_desabonne = 0 THEN NULL 
      ELSE covar / (stddev_retards * stddev_desabonne) 
    END AS correlation_pearson
FROM Covariance CROSS JOIN Stats;
GO
-- ✅ Résultat attendu :
-- correlation_pearson
-- --------------------
-- 0.666666666666667


