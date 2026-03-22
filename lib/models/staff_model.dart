class Staff {
  final String id;
  final String name;
  final String role;

  Staff({required this.id, required this.name, required this.role});

  Staff copyWith({String? name, String? role}) {
    return Staff(id: id, name: name ?? this.name, role: role ?? this.role);
  }
}
