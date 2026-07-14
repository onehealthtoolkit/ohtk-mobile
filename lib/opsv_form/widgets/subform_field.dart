part of 'widgets.dart';

class FormSubformField extends StatefulWidget {
  final opsv.SubformField field;

  const FormSubformField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormSubformField> createState() => _FormSubformFieldState();
}

class _FormSubformFieldState extends State<FormSubformField> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      if (!widget.field.display) {
        return const SizedBox.shrink();
      }
      final subforms = widget.field.forms;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < subforms.length; i++) ...[
            _SubformItemCard(
              key: ValueKey(subforms[i].ref.id),
              field: widget.field,
              subform: subforms[i],
              index: i + 1,
              onOpen: () => _openEditor(context, subforms[i]),
              onDelete: () => _confirmDelete(context, subforms[i]),
            ),
            if (i != subforms.length - 1) const SizedBox(height: 8),
          ],
          if (subforms.isNotEmpty) const SizedBox(height: 10),
          _AddAnotherButton(onTap: () => _openCreate(context)),
        ],
      );
    });
  }

  Future<void> _openCreate(BuildContext context) async {
    final subform = widget.field.newSubform();
    final title = widget.field.getSubformRecordTitle();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubformFormView(
          widget.field.form.testFlag,
          title,
          subform.ref,
        ),
      ),
    );
    if (result is String && result == 'complete') {
      widget.field.addSubform(subform);
    }
  }

  Future<void> _openEditor(BuildContext context, opsv.Subform subform) async {
    final title = widget.field.getSubformRecordTitle(subform.name);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubformFormView(
          widget.field.form.testFlag,
          title,
          subform.ref,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    opsv.Subform subform,
  ) async {
    final localize = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          localize.subformDeleteConfirmTitle,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: incidentsInk,
          ),
        ),
        content: Text(
          localize.subformDeleteConfirmBody,
          style: const TextStyle(
            fontFamily: incidentsFontFamily,
            fontFamilyFallback: incidentsFontFamilyFallback,
            fontSize: 13,
            color: incidentsMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: incidentsInk),
            child: Text(
              localize.exitDialogKeepButton,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: incidentsErrorRed),
            child: Text(
              localize.subformDeleteConfirmAction,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.field.deleteSubform(subform);
    }
  }
}

class _SubformItemCard extends StatelessWidget {
  final opsv.SubformField field;
  final opsv.Subform subform;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _SubformItemCard({
    Key? key,
    required this.field,
    required this.subform,
    required this.index,
    required this.onOpen,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = subform.evaluatedTitle;
    final summary = subform.evaluatedDescription;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _ohtkFormBrandTint(0.05),
            border: Border.all(
              color: _ohtkFormBrandTint(0.18),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IndexPill(index: index),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.isNotEmpty ? title : field.label ?? field.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: incidentsInk,
                        height: 1.3,
                      ),
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: incidentsFontFamily,
                          fontFamilyFallback: incidentsFontFamilyFallback,
                          fontSize: 11.5,
                          color: incidentsMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _IconAction(
                icon: Icons.edit_outlined,
                color: incidentsMuted,
                onTap: onOpen,
              ),
              _IconAction(
                icon: Icons.delete_outline,
                color: incidentsErrorRed,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexPill extends StatelessWidget {
  final int index;
  const _IndexPill({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _ohtkFormBrand,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          fontFamily: incidentsFontFamily,
          fontFamilyFallback: incidentsFontFamilyFallback,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _AddAnotherButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAnotherButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DottedBorder(
        color: _ohtkFormBrand,
        strokeWidth: 1.5,
        dashPattern: const [5, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        padding: EdgeInsets.zero,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: _ohtkFormBrand),
              const SizedBox(width: 8),
              Text(
                localize.addAnotherSubformButton,
                style: TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: _ohtkFormBrand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
