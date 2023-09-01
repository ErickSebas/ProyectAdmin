class Campaign {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;

  Campaign({required this.id, required this.nombre, required this.descripcion, required this.categoria});
}

class CampaignManager {
  List<Campaign> _campaigns = [
    Campaign(id: 1, nombre: "Campaña 1", descripcion: "Descripción Campaña 1", categoria: "Categoría 1"),
    Campaign(id: 2, nombre: "Campaña 2", descripcion: "Descripción Campaña 2", categoria: "Categoría 2"),
    Campaign(id: 3, nombre: "Campaña 3", descripcion: "Descripción Campaña 3", categoria: "Categoría 3"),
  ];

  // Getter para obtener la lista de campañas
  List<Campaign> get campaigns => _campaigns;

  // Setter para modificar la lista de campañas
  set campaigns(List<Campaign> newCampaigns) {
    _campaigns = newCampaigns;
  }
}
