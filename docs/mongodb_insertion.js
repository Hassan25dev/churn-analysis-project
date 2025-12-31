// =========================================================
// 📥 Insertion des logs d'activité client dans MongoDB
// Projet : Churn des abonnés – Bootcamp JobInTech
// =========================================================

db.logs_activite.insertMany([
  { id_client: 1, timestamp: "2024-10-20T09:00:00Z", action: "connexion", device: "mobile" },
  { id_client: 1, timestamp: "2024-10-21T10:00:00Z", action: "video", device: "desktop" },
  { id_client: 2, timestamp: "2024-09-15T18:00:00Z", action: "connexion", device: "mobile" },
  { id_client: 3, timestamp: "2024-10-10T09:30:00Z", action: "quiz", device: "tablet" },
  { id_client: 3, timestamp: "2024-10-11T09:30:00Z", action: "connexion", device: "tablet" }
]);

// =========================================================
// 🔍 Agrégation pour résumer l’activité
// Résultat : fréquence + dernier appareil
// =========================================================

db.logs_activite.aggregate([
  {
    $group: {
      _id: "$id_client",
      freq_connexion: { $sum: 1 },
      dernier_device: { $last: "$device" }
    }
  },
  {
    $out: "resume_logs"  // Exportable vers SQL
  }
]);