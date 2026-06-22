import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/review_provider.dart';
import '../core/routes.dart';
import 'components/reusable_crud_table.dart';
import 'components/statistic_card.dart';

class ReviewsAdminPage extends StatefulWidget {
  const ReviewsAdminPage({super.key});

  @override
  State<ReviewsAdminPage> createState() => _ReviewsAdminPageState();
}

class _ReviewsAdminPageState extends State<ReviewsAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _loading = false;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _loading = true);
    context
        .read<ReviewProvider>()
        .getAll(
          search: _searchController.text,
          page: _currentPage,
          filters: _filters,
        )
        .then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _openFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => ReviewFilterDialog(
        initialFilters: _filters,
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
        _currentPage = 1;
      });
      _loadData();
    }
  }

  Future<void> _confirmDelete(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Reseña'),
        content: Text(
            '¿Está seguro de que desea eliminar la reseña con ID "${review.id}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final success =
          await context.read<ReviewProvider>().deleteReview(review.id);
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Reseña eliminada con éxito'
                : 'Error al eliminar la reseña'),
          ),
        );
        if (success) _loadData();
      }
    }
  }

  Widget _buildStars(int value) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(Icon(
        i <= value ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      ));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.reviews;
    final totalCount = reviewProvider.reviewsCount;
    final totalPages = (totalCount / _itemsPerPage).ceil();

    // Local stats calculations
    double avgRating = 0;
    int fiveStarCount = 0;
    int badReviewCount = 0;

    if (reviews.isNotEmpty) {
      double sum = 0;
      for (var r in reviews) {
        sum += r.value;
        if (r.value == 5) fiveStarCount++;
        if (r.value <= 2) badReviewCount++;
      }
      avgRating = sum / reviews.length;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                const Text(
                  'Gestión de Calidad',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(
                  'Reseñas de Usuarios',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Administración de Reseñas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supervisión y control de las valoraciones de satisfacción enviadas por los ciudadanos sobre reportes y trámites.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Section
            Row(
              children: [
                Expanded(
                  child: StatisticCard(
                    label: 'TOTAL RESEÑAS',
                    value: totalCount.toString(),
                    icon: Icons.rate_review,
                    color: Colors.blue[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'PROMEDIO (PÁGINA)',
                    value:
                        reviews.isEmpty ? '0.0' : avgRating.toStringAsFixed(1),
                    icon: Icons.star,
                    color: Colors.amber[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'EXCELENTES (5★)',
                    value: fiveStarCount.toString(),
                    icon: Icons.sentiment_very_satisfied,
                    color: Colors.green[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatisticCard(
                    label: 'INSATISFACTORIAS (<=2★)',
                    value: badReviewCount.toString(),
                    icon: Icons.sentiment_very_dissatisfied,
                    color: Colors.red[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por reseña o usuario...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
                    },
                    onSubmitted: (value) {
                      setState(() => _currentPage = 1);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtrar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _openFiltersDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ReusableCrudTable<ReviewModel>(
                headers: const [
                  'Calificación',
                  'Usuario ID',
                  'Reporte ID',
                  'Trámite ID',
                  'Fecha de Creación',
                  'Acciones'
                ],
                flexes: const [2, 2, 2, 2, 2, 1],
                items: reviews,
                currentPage: _currentPage,
                totalPages: totalPages,
                totalCount: totalCount,
                itemsPerPage: _itemsPerPage,
                emptyMessage: 'No se encontraron reseñas registradas.',
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _loadData();
                },
                rowBuilder: (context, review, index) {
                  final formattedDate =
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}';
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStars(review.value),
                              const SizedBox(height: 2),
                              Text(
                                '${review.value} de 5',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IconButton(
                          tooltip: 'Usuario',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.userDetail,
                              arguments: UserDetailArguments(
                                  userId: review.user,
                                  isEditMode: false), // o true para edición
                            );
                          },
                          icon: const Icon(Icons.person),
                          iconSize: 20,
                          splashRadius: 20,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: Text(
                        //     review.user,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: const TextStyle(fontSize: 12),
                        //   ),
                        // ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            review.report ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: review.report != null
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            review.tramite ?? 'N/A',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: review.tramite != null
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(formattedDate),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => _confirmDelete(review),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 20,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ReviewFilterDialog extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const ReviewFilterDialog({required this.initialFilters, super.key});

  @override
  State<ReviewFilterDialog> createState() => _ReviewFilterDialogState();
}

class _ReviewFilterDialogState extends State<ReviewFilterDialog> {
  late Map<String, dynamic> _filters;

  // Controllers
  late TextEditingController _idController;
  late TextEditingController _userController;
  late TextEditingController _curpController;
  late TextEditingController _emailController;
  late TextEditingController _reportController;
  late TextEditingController _tramiteController;
  late TextEditingController _valueController;
  late TextEditingController _createdAtController;

  // Operators
  String _valueOp = 'exact';
  String _createdAtOp = 'exact';

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);

    _idController = TextEditingController(text: _filters['id'] ?? '');
    _userController = TextEditingController(text: _filters['user'] ?? '');
    _curpController =
        TextEditingController(text: _filters['user__curp__icontains'] ?? '');
    _emailController =
        TextEditingController(text: _filters['user__email__icontains'] ?? '');
    _reportController = TextEditingController(text: _filters['report'] ?? '');
    _tramiteController = TextEditingController(text: _filters['tramite'] ?? '');

    // Resolve value and op
    String valText = '';
    if (_filters.containsKey('value')) {
      valText = _filters['value'].toString();
      _valueOp = 'exact';
    } else if (_filters.containsKey('value__exact')) {
      valText = _filters['value__exact'].toString();
      _valueOp = 'exact';
    } else if (_filters.containsKey('value__gte')) {
      valText = _filters['value__gte'].toString();
      _valueOp = 'gte';
    } else if (_filters.containsKey('value__lte')) {
      valText = _filters['value__lte'].toString();
      _valueOp = 'lte';
    } else if (_filters.containsKey('value__range')) {
      valText = _filters['value__range'].toString();
      _valueOp = 'range';
    }
    _valueController = TextEditingController(text: valText);

    // Resolve created_at and op
    String createdAtVal = '';
    if (_filters.containsKey('created_at')) {
      createdAtVal = _filters['created_at'].toString();
      _createdAtOp = 'exact';
    } else if (_filters.containsKey('created_at__exact')) {
      createdAtVal = _filters['created_at__exact'].toString();
      _createdAtOp = 'exact';
    } else if (_filters.containsKey('created_at__gte')) {
      createdAtVal = _filters['created_at__gte'].toString();
      _createdAtOp = 'gte';
    } else if (_filters.containsKey('created_at__lte')) {
      createdAtVal = _filters['created_at__lte'].toString();
      _createdAtOp = 'lte';
    } else if (_filters.containsKey('created_at__range')) {
      createdAtVal = _filters['created_at__range'].toString();
      _createdAtOp = 'range';
    }
    _createdAtController = TextEditingController(text: createdAtVal);
  }

  @override
  void dispose() {
    _idController.dispose();
    _userController.dispose();
    _curpController.dispose();
    _emailController.dispose();
    _reportController.dispose();
    _tramiteController.dispose();
    _valueController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  void _apply() {
    _filters.clear();

    if (_idController.text.isNotEmpty) {
      _filters['id'] = _idController.text;
    }
    if (_userController.text.isNotEmpty) {
      _filters['user'] = _userController.text;
    }
    if (_curpController.text.isNotEmpty) {
      _filters['user__curp__icontains'] = _curpController.text;
    }
    if (_emailController.text.isNotEmpty) {
      _filters['user__email__icontains'] = _emailController.text;
    }
    if (_reportController.text.isNotEmpty) {
      _filters['report'] = _reportController.text;
    }
    if (_tramiteController.text.isNotEmpty) {
      _filters['tramite'] = _tramiteController.text;
    }
    if (_valueController.text.isNotEmpty) {
      final key = _valueOp == 'exact' ? 'value' : 'value__$_valueOp';
      _filters[key] =
          int.tryParse(_valueController.text) ?? _valueController.text;
    }
    if (_createdAtController.text.isNotEmpty) {
      final key =
          _createdAtOp == 'exact' ? 'created_at' : 'created_at__$_createdAtOp';
      _filters[key] = _createdAtController.text;
    }

    Navigator.of(context).pop({..._filters});
  }

  void _clear() {
    setState(() {
      _filters.clear();
      _idController.clear();
      _userController.clear();
      _curpController.clear();
      _emailController.clear();
      _reportController.clear();
      _tramiteController.clear();
      _valueController.clear();
      _createdAtController.clear();
      _valueOp = 'exact';
      _createdAtOp = 'exact';
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (_createdAtOp == 'range') {
          if (_createdAtController.text.isEmpty) {
            _createdAtController.text = formatted;
          } else {
            _createdAtController.text =
                "${_createdAtController.text},$formatted";
          }
        } else {
          _createdAtController.text = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros Avanzados (Reseñas)'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID Reseña
              const Text('ID de Reseña (Exacto)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: 'UUID de la reseña...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // ID Usuario
              const Text('ID de Usuario (Exacto)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  hintText: 'UUID del usuario...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // CURP Usuario
              const Text('CURP de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _curpController,
                decoration: InputDecoration(
                  hintText: 'CURP del usuario...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Email Usuario
              const Text('Email de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico del usuario...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // ID Reporte
              const Text('ID de Reporte (Exacto)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _reportController,
                decoration: InputDecoration(
                  hintText: 'UUID del reporte asociado...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // ID Trámite
              const Text('ID de Trámite (Exacto)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _tramiteController,
                decoration: InputDecoration(
                  hintText: 'UUID del trámite asociado...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),

              // Calificación (value)
              const Text('Calificación (1 - 5)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        hintText:
                            _valueOp == 'range' ? 'Ej. 1,3' : 'Calificación...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _valueOp,
                      items: const [
                        DropdownMenuItem(value: 'exact', child: Text('Exacto')),
                        DropdownMenuItem(value: 'gte', child: Text('Min (>=)')),
                        DropdownMenuItem(value: 'lte', child: Text('Max (<=)')),
                        DropdownMenuItem(
                            value: 'range', child: Text('Rango (A,B)')),
                      ],
                      onChanged: (v) => setState(() => _valueOp = v ?? 'exact'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fecha de Creación
              const Text('Fecha de Creación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _createdAtController,
                      decoration: InputDecoration(
                        hintText: _createdAtOp == 'range'
                            ? 'YYYY-MM-DD,YYYY-MM-DD'
                            : 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          onPressed: _selectDate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _createdAtOp,
                      items: const [
                        DropdownMenuItem(value: 'exact', child: Text('Exacta')),
                        DropdownMenuItem(
                            value: 'gte', child: Text('Desde (>=)')),
                        DropdownMenuItem(
                            value: 'lte', child: Text('Hasta (<=)')),
                        DropdownMenuItem(
                            value: 'range', child: Text('Rango (A,B)')),
                      ],
                      onChanged: (v) =>
                          setState(() => _createdAtOp = v ?? 'exact'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _clear, child: const Text('Limpiar')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }
}
