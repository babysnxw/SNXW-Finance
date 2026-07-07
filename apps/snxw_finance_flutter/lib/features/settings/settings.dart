import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/design/design.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Configuración"),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Sección de Perfil
            _buildSectionHeader(context, "Perfil de Usuario"),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
                title: const Text("Información Personal"),
                subtitle: const Text("Nombre, correo, foto de perfil"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Navegar a perfil
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Colors.green,
                  ),
                ),
                title: const Text("Seguridad"),
                subtitle: const Text("Cambiar contraseña, autenticación"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Navegar a seguridad
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección de Preferencias
            _buildSectionHeader(context, "Preferencias"),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: SwitchListTile(
                title: const Text("Modo Oscuro"),
                subtitle: const Text("Cambiar tema de la aplicación"),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  // TODO: Implementar cambio de tema
                },
                activeThumbColor: Colors.blue, activeTrackColor: Colors.blue.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.orange,
                  ),
                ),
                title: const Text("Notificaciones"),
                subtitle: const Text("Configurar alertas y recordatorios"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Navegar a notificaciones
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Colors.purple,
                  ),
                ),
                title: const Text("Idioma"),
                subtitle: const Text("Español (ES)"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Cambiar idioma
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección de Datos
            _buildSectionHeader(context, "Datos y Almacenamiento"),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.backup_rounded,
                    color: Colors.red,
                  ),
                ),
                title: const Text("Exportar Datos"),
                subtitle: const Text("Exportar tus datos a un archivo"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Exportar datos
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.grey,
                  ),
                ),
                title: const Text("Limpiar Datos"),
                subtitle: const Text("Eliminar todos los datos guardados"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  _showDeleteConfirmation(context);
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Sección de Información
            _buildSectionHeader(context, "Información"),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
                title: const Text("Acerca de SNXW Finance"),
                subtitle: const Text("Versión 0.1.0"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.green,
                  ),
                ),
                title: const Text("Ayuda"),
                subtitle: const Text("Preguntas frecuentes y soporte"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Abrir ayuda
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.label.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Eliminar todos los datos?"),
          content: const Text(
            "Esta acción eliminará permanentemente todos tus datos financieros. ¿Estás seguro de que deseas continuar?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Implementar limpieza de datos
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Datos eliminados correctamente."),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "SNXW Finance",
      applicationVersion: "0.1.0",
      applicationLegalese: "© 2024 SNXW Labs",
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          "Una aplicación moderna de finanzas personales diseñada para ayudarte a tomar mejores decisiones financieras.",
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Desarrollado con ❤️ por SNXW Labs",
          style: AppTypography.label.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}