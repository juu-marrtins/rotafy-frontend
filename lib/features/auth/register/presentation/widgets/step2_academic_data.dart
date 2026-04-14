import 'package:flutter/material.dart';
import 'package:rotafy_frontend/core/theme/roy_theme.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';

class Step2AcademicData extends StatefulWidget {
  final TextEditingController cnpjController;
  final TextEditingController academicProfileController;
  final String? selectedProfile;
  final Function(String) onProfileSelected;
  final TextEditingController passwordController;
  final VoidCallback onNext;
  final String? errorMessage;
  final Function(Uint8List bytes, String fileName)? onPhotoPicked;

  const Step2AcademicData({
    super.key,
    required this.cnpjController,
    required this.academicProfileController,
    required this.selectedProfile,
    required this.onProfileSelected,
    required this.passwordController,
    required this.onNext,
    this.errorMessage,
    this.onPhotoPicked
  });

  @override
  State<Step2AcademicData> createState() => _Step2AcademicDataState();
}

class _Step2AcademicDataState extends State<Step2AcademicData> {
    List<String> results = [];
    Uint8List? _profileImage;

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
          final bytes = reader.result as Uint8List;
          setState(() {
            _profileImage = bytes;
          });
          widget.onPhotoPicked?.call(bytes, file.name);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage();
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: RoyColors.blueNavy.withOpacity(0.08),
                      backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 48, color: RoyColors.blueNavy)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: RoyColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 13,
                  color: RoyColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const _FieldLabel('CNPJ da universidade'),
        const SizedBox(height: 6),
        TextField(
          controller: widget.cnpjController,
          decoration: RoyTheme.fieldDecoration(
            placeholder: '00.000.000/0000-00',
          ),
        ),

        const SizedBox(height: 16),

        const _FieldLabel('Perfil acadêmico'),
        const SizedBox(height: 6),
  
        Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,    
            highlightColor: Colors.transparent, 
            splashColor: Colors.transparent,    
          ),
          child: DropdownButtonFormField<String>(
            value: widget.selectedProfile,
            hint: const Text('Selecione'),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(
                value: 'teacher',
                child: Text('Professor'),
              ),
              DropdownMenuItem(
                value: 'student',
                child: Text('Aluno'),
              ),
              DropdownMenuItem(
                value: 'employee',
                child: Text('Funcionario'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onProfileSelected(value);
              }
            },
            decoration: RoyTheme.fieldDecoration(
              placeholder: 'Selecione',
            ),
          ),
        ),

        const _FieldLabel('Senha'),
        const SizedBox(height: 6),
        TextField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: RoyTheme.fieldDecoration(
            placeholder: '******',
          ),
        ),

        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 16),

        // Botão Avançar
        ElevatedButton(
          onPressed: widget.onNext,
          style: RoyTheme.primaryButton(),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: RoyColors.textPrimary,
      ),
    );
  }
}
