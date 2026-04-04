import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learning_admin_app/models/course_model.dart';
import 'package:learning_admin_app/utils/image_cropper.dart';
import 'package:learning_admin_app/utils/image_preview.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_bold_text.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_button_one.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_primary_text.dart';
import 'package:learning_admin_app/pages/widgets/Custom/custom_text_box.dart';

class AddCoursePage extends StatefulWidget {
  final Course course;
  const AddCoursePage({super.key, required this.course});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  final _basicFormKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl = TextEditingController();
  late TextEditingController _subtitleCtrl = TextEditingController();
  late TextEditingController _bannerCtrl = TextEditingController();
  String _languageTag = 'EN';
  String _categoryTag = 'FULL SYLLABUS BATCH';

  DateTime? _batchStartDate;
  DateTime? _enrollmentEndDate;

  final List<_EducatorEntry> _educators = [_EducatorEntry()];

  final _aboutFormKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _highlightCtrl = TextEditingController();
  final List<String> _highlights = [];
  final _liveClassesCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final List<String> _teachingLangs = [];

  final _pricingFormKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  String _currency = 'INR';
  bool _isFree = false;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.course.title);
    _subtitleCtrl = TextEditingController(text: widget.course.description);
    _bannerCtrl = TextEditingController(text: widget.course.course_image);
  }

  void _animateTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicFormKey.currentState?.validate() ?? false;
      case 1:
        if (_batchStartDate == null || _enrollmentEndDate == null) {
          _snack('Please select both dates');
          return false;
        }
        return true;
      case 2:
        for (final e in _educators) {
          if (e.nameCtrl.text.trim().isEmpty) {
            _snack('All educator names are required');
            return false;
          }
        }
        return true;
      case 3:
        return _aboutFormKey.currentState?.validate() ?? false;
      case 4:
        return _pricingFormKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );

  void _submit() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Customboldtext(text: 'Add Course', fontValue: 18),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepIndicator(
            current: _currentStep,
            total: _totalSteps,
            onTap: _animateTo,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1BasicInfo(
            formKey: _basicFormKey,
            titleCtrl: _titleCtrl,
            subtitleCtrl: _subtitleCtrl,
            bannerCtrl: _bannerCtrl,
            languageTag: _languageTag,
            categoryTag: _categoryTag,
            onLanguageChanged: (v) => setState(() => _languageTag = v!),
            onCategoryChanged: (v) => setState(() => _categoryTag = v!),
          ),
          _Step2Dates(
            batchStartDate: _batchStartDate,
            enrollmentEndDate: _enrollmentEndDate,
            onBatchStartPicked: (d) => setState(() => _batchStartDate = d),
            onEnrollmentEndPicked: (d) =>
                setState(() => _enrollmentEndDate = d),
          ),
          _Step3Educators(
            educators: _educators,
            onAdd: () => setState(() => _educators.add(_EducatorEntry())),
            onRemove: (i) => setState(() => _educators.removeAt(i)),
          ),
          _Step4AboutStats(
            formKey: _aboutFormKey,
            descCtrl: _descCtrl,
            highlightCtrl: _highlightCtrl,
            highlights: _highlights,
            liveClassesCtrl: _liveClassesCtrl,
            langCtrl: _langCtrl,
            teachingLangs: _teachingLangs,
            onAddHighlight: () {
              final v = _highlightCtrl.text.trim();
              if (v.isNotEmpty) {
                setState(() {
                  _highlights.add(v);
                  _highlightCtrl.clear();
                });
              }
            },
            onRemoveHighlight: (i) => setState(() => _highlights.removeAt(i)),
            onAddLang: () {
              final v = _langCtrl.text.trim();
              if (v.isNotEmpty) {
                setState(() {
                  _teachingLangs.add(v);
                  _langCtrl.clear();
                });
              }
            },
            onRemoveLang: (i) => setState(() => _teachingLangs.removeAt(i)),
          ),
          _Step5Pricing(
            formKey: _pricingFormKey,
            priceCtrl: _priceCtrl,
            currency: _currency,
            isFree: _isFree,
            isEnrolled: _isEnrolled,
            onCurrencyChanged: (v) => setState(() => _currency = v!),
            onIsFreeChanged: (v) => setState(() => _isFree = v ?? false),
            onIsEnrolledChanged: (v) =>
                setState(() => _isEnrolled = v ?? false),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentStep: _currentStep,
        totalSteps: _totalSteps,
        onBack: _currentStep > 0 ? () => _animateTo(_currentStep - 1) : null,
        onNext: () {
          if (!_validateCurrentStep()) return;
          if (_currentStep < _totalSteps - 1) {
            _animateTo(_currentStep + 1);
          } else {
            _submit();
          }
        },
        isLast: _currentStep == _totalSteps - 1,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.current,
    required this.total,
    required this.onTap,
  });

  final int current, total;
  final ValueChanged<int> onTap;

  static const _labels = ['Basic', 'Dates', 'Educators', 'Details', 'Pricing'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(total, (i) {
          final active = i == current;
          final done = i < current;
          return Expanded(
            child: GestureDetector(
              onTap: done ? () => onTap(i) : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || active ? cs.primary : cs.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? cs.primary
                                : done
                                ? cs.primary.withOpacity(0.6)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < total - 1) const SizedBox(width: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.isLast,
  });

  final int currentStep, totalSteps;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            Expanded(
              child: Custombuttonone(text: 'Back', onTap: onBack),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Custombuttonone(
              text: isLast ? 'Save Course' : 'Continue',
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Customboldtext(text: title, fontValue: 18),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Customprimarytext(text: subtitle!, fontValue: 13),
      ],
      const SizedBox(height: 20),
    ],
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Customboldtext(text: text, fontValue: 13),
  );
}

Widget _chipRow(List<String> items, void Function(int) onRemove) =>
    items.isEmpty
    ? const SizedBox.shrink()
    : Wrap(
        spacing: 8,
        runSpacing: 6,
        children: List.generate(
          items.length,
          (i) => Chip(
            label: Text(items[i], style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => onRemove(i),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ),
      );

class _Step1BasicInfo extends StatefulWidget {
  const _Step1BasicInfo({
    required this.formKey,
    required this.titleCtrl,
    required this.subtitleCtrl,
    required this.bannerCtrl,
    required this.languageTag,
    required this.categoryTag,
    required this.onLanguageChanged,
    required this.onCategoryChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl, subtitleCtrl, bannerCtrl;
  final String languageTag, categoryTag;
  final ValueChanged<String?> onLanguageChanged, onCategoryChanged;

  @override
  State<_Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<_Step1BasicInfo> {
  final double _aspectRatio = 4 / 3;
  String? newCourseImage;
  bool _keepExistingImage = true;
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final String pickedImagePath = result.files.single.path!;

      final String? croppedImagePath = await ImageCropHelper.cropImage(
        context,
        pickedImagePath,
        aspectRatio: _aspectRatio,
      );

      if (croppedImagePath != null) {
        setState(() {
          newCourseImage = croppedImagePath;
          widget.bannerCtrl.text = croppedImagePath;
          _keepExistingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            'Basic Info',
            subtitle: 'Course title, category and media',
          ),
          const _Label('Course Title'),
          Customtextbox(
            hinttext: 'Course Title',
            textController: widget.titleCtrl,
            textFieldIcon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 16),
          const _Label('Subtitle'),
          Customtextbox(
            hinttext: 'Short description ',
            textController: widget.subtitleCtrl,
            textFieldIcon: Icons.short_text,
          ),
          const SizedBox(height: 16),
          const _Label('Banner Image '),
          Center(child: _buildImageWidget()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Language'),
                    DropdownButtonFormField<String>(
                      value: widget.languageTag,
                      decoration: const InputDecoration(),
                      items: ['EN', 'HIN', 'MAL', 'TAM']
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: widget.onLanguageChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Category'),
                    DropdownButtonFormField<String>(
                      value: widget.categoryTag,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      items:
                          [
                                'FULL SYLLABUS BATCH',
                                'CRASH COURSE',
                                'TOPIC WISE',
                                'TEST SERIES',
                              ]
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: widget.onCategoryChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget _buildImageWidget() {
    if (newCourseImage != null && newCourseImage!.isNotEmpty) {
      return AspectRatioImageField(
        imagePath: newCourseImage!,
        aspectRatio: _aspectRatio,
        onPick: _pickFile,
        onRemove: () {
          setState(() {
            newCourseImage = null;
          });
        },
      );
    }
    if (_keepExistingImage && widget.bannerCtrl.text.isNotEmpty) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.bannerCtrl.text,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _keepExistingImage = false;
                  widget.bannerCtrl.text = "";
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40),
            SizedBox(height: 8),
            Text("Select Image for the Course"),
          ],
        ),
      ),
    );
  }
}

class _Step2Dates extends StatelessWidget {
  const _Step2Dates({
    required this.batchStartDate,
    required this.enrollmentEndDate,
    required this.onBatchStartPicked,
    required this.onEnrollmentEndPicked,
  });

  final DateTime? batchStartDate, enrollmentEndDate;
  final ValueChanged<DateTime?> onBatchStartPicked, onEnrollmentEndPicked;

  Future<void> _pick(
    BuildContext ctx,
    DateTime? initial,
    ValueChanged<DateTime?> onPicked,
  ) async {
    final d = await showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    onPicked(d);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          'Schedule',
          subtitle: 'When does the batch start and enrollment close?',
        ),
        _DateTile(
          label: 'Batch Start Date',
          date: batchStartDate,
          onTap: () => _pick(context, batchStartDate, onBatchStartPicked),
        ),
        const SizedBox(height: 16),
        _DateTile(
          label: 'Enrollment End Date',
          date: enrollmentEndDate,
          onTap: () => _pick(context, enrollmentEndDate, onEnrollmentEndPicked),
        ),
      ],
    ),
  );
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,

              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.tertiary,
                ),
                const SizedBox(width: 10),
                date != null
                    ? Text(
                        '${date!.day}/${date!.month}/${date!.year}',
                        style: TextStyle(color: Colors.black),
                      )
                    : const Text(
                        'Select date',
                        style: TextStyle(color: Colors.black),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EducatorEntry {
  final nameCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
}

class _Step3Educators extends StatefulWidget {
  const _Step3Educators({
    required this.educators,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_EducatorEntry> educators;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  State<_Step3Educators> createState() => _Step3EducatorsState();
}

class _Step3EducatorsState extends State<_Step3Educators> {
  final double _aspectRatio = 4 / 3;

  Future<void> _pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final String pickedImagePath = result.files.single.path!;

      final String? croppedImagePath = await ImageCropHelper.cropImage(
        context,
        pickedImagePath,
        aspectRatio: _aspectRatio,
      );

      if (croppedImagePath != null) {
        setState(() {
          widget.educators[index].imageCtrl.text = croppedImagePath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          'Educators',
          subtitle: 'Add teachers for this course',
        ),
        ...List.generate(widget.educators.length, (i) {
          final e = widget.educators[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Customboldtext(text: 'Educator ${i + 1}', fontValue: 13),
                      if (widget.educators.length > 1)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () => widget.onRemove(i),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _Label('Name'),
                  Customtextbox(
                    hinttext: 'Full name',
                    textController: e.nameCtrl,
                    textFieldIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  const _Label('Profile Image URL'),
                  Center(
                    child: AspectRatioImageField(
                      imagePath: e.imageCtrl.text,
                      aspectRatio: _aspectRatio,
                      onPick: () => _pickFile(i),
                      onRemove: () => setState(() => e.imageCtrl.text = ""),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Center(
          child: Custombuttonone(text: 'Add Educator', onTap: widget.onAdd),
        ),
      ],
    ),
  );
}

class _Step4AboutStats extends StatelessWidget {
  const _Step4AboutStats({
    required this.formKey,
    required this.descCtrl,
    required this.highlightCtrl,
    required this.highlights,
    required this.liveClassesCtrl,
    required this.langCtrl,
    required this.teachingLangs,
    required this.onAddHighlight,
    required this.onRemoveHighlight,
    required this.onAddLang,
    required this.onRemoveLang,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descCtrl,
      highlightCtrl,
      liveClassesCtrl,
      langCtrl;
  final List<String> highlights, teachingLangs;
  final VoidCallback onAddHighlight, onAddLang;
  final ValueChanged<int> onRemoveHighlight, onRemoveLang;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            'About & Stats',
            subtitle: 'Description, highlights and class info',
          ),

          // Description — multiline needs a plain TextFormField
          // since Customtextbox does not expose maxLines
          const _Label('Description'),
          TextFormField(
            controller: descCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.description_outlined,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: 'What will students learn?',
              hintStyle: const TextStyle(color: Colors.black),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'This field is required'
                : null,
          ),
          const SizedBox(height: 16),

          const _Label('Highlights'),
          Row(
            children: [
              Expanded(
                child: Customtextbox(
                  hinttext: 'e.g. 200+ hours of video',
                  textController: highlightCtrl,
                  textFieldIcon: Icons.star_outline,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddHighlight,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _chipRow(highlights, onRemoveHighlight),
          const SizedBox(height: 20),

          const Divider(),
          const SizedBox(height: 16),

          const _Label('Live Classes Count'),
          Customtextbox(
            hinttext: 'e.g. 120',
            textController: liveClassesCtrl,
            textFieldIcon: Icons.live_tv_outlined,
          ),
          const SizedBox(height: 16),

          const _Label('Teaching Languages'),
          Row(
            children: [
              Expanded(
                child: Customtextbox(
                  hinttext: 'e.g. English',
                  textController: langCtrl,
                  textFieldIcon: Icons.language,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddLang,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _chipRow(teachingLangs, onRemoveLang),
        ],
      ),
    ),
  );
}

class _Step5Pricing extends StatelessWidget {
  const _Step5Pricing({
    required this.formKey,
    required this.priceCtrl,
    required this.currency,
    required this.isFree,
    required this.isEnrolled,
    required this.onCurrencyChanged,
    required this.onIsFreeChanged,
    required this.onIsEnrolledChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController priceCtrl;
  final String currency;
  final bool isFree, isEnrolled;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<bool?> onIsFreeChanged, onIsEnrolledChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            'Pricing',
            subtitle: 'Set the course price and enrollment defaults',
          ),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Price'),
                    IgnorePointer(
                      ignoring: isFree,
                      child: Opacity(
                        opacity: isFree ? 0.5 : 1.0,
                        child: Customtextbox(
                          hinttext: '0.00',
                          textController: priceCtrl,
                          textFieldIcon: Icons.currency_rupee,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _ToggleTile(
            title: 'Free Course',
            subtitle: 'No payment required to enroll',
            value: isFree,
            onChanged: onIsFreeChanged,
          ),
          const SizedBox(height: 12),
          _ToggleTile(
            title: 'Default as Enrolled',
            subtitle: 'Students are enrolled on course creation',
            value: isEnrolled,
            onChanged: onIsEnrolledChanged,
          ),
        ],
      ),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title, subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE2E8F0)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: CheckboxListTile(
      value: value,
      onChanged: onChanged,
      tileColor: Colors.black,
      title: Text(title, style: TextStyle(fontSize: 14, color: Colors.black)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    ),
  );
}
