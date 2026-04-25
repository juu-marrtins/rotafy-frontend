import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rotafy_frontend/core/http/api_client.dart';

Future<bool> showRechargeModal(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const RechargeModal(),
  );
  return result ?? false;
}

class RechargeModal extends StatefulWidget {
  const RechargeModal({super.key});

  @override
  State<RechargeModal> createState() => _RechargeModalState();
}

enum _Step { amount, loading, qr, error }

class _RechargeModalState extends State<RechargeModal> {
  _Step _step = _Step.amount;

  final List<double> _presets = [20, 50, 100, 200];
  double? _selectedAmount;
  final _customController = TextEditingController();
  final _customFocus = FocusNode();

  String _pixKey = '';
  String _qrCodeBase64 = '';
  double _confirmedAmount = 0;
  String _errorMessage = '';

  bool get _isValid => _selectedAmount != null && _selectedAmount! >= 5;

  @override
  void dispose() {
    _customController.dispose();
    _customFocus.dispose();
    super.dispose();
  }

  void _selectPreset(double value) {
    _customController.clear();
    _customFocus.unfocus();
    setState(() => _selectedAmount = value);
  }

  void _onCustomChanged(String v) {
    final parsed = double.tryParse(v);
    setState(() => _selectedAmount = (parsed != null && parsed >= 5) ? parsed : null);
  }

  Future<void> _requestRecharge() async {
    if (!_isValid) return;
    setState(() => _step = _Step.loading);

    try {
      final response = await ApiClient.post(
        '/v1/passenger/wallet/recharge',
        {'amount': _selectedAmount},
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(json['message'] ?? 'Erro desconhecido');
      }

      final data = json['data'];
      setState(() {
        _pixKey = data['pix_key'] ?? '';
        _qrCodeBase64 = data['qr_code_url'] ?? '';
        _confirmedAmount = double.tryParse(data['amount'].toString()) ?? _selectedAmount!;
        _step = _Step.qr;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _step = _Step.error;
      });
    }
  }

  void _copyPixKey() {
    Clipboard.setData(ClipboardData(text: _pixKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código PIX copiado!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: switch (_step) {
              _Step.amount  => _AmountStep(
                  key: const ValueKey('amount'),
                  presets: _presets,
                  selectedAmount: _selectedAmount,
                  customController: _customController,
                  customFocus: _customFocus,
                  isValid: _isValid,
                  onSelectPreset: _selectPreset,
                  onCustomChanged: _onCustomChanged,
                  onConfirm: _requestRecharge,
                ),
              _Step.loading => const _LoadingStep(key: ValueKey('loading')),
              _Step.qr      => _QrStep(
                  key: const ValueKey('qr'),
                  amount: _confirmedAmount,
                  pixKey: _pixKey,
                  qrCodeBase64: _qrCodeBase64,
                  onCopy: _copyPixKey,
                  onBack: () => setState(() => _step = _Step.amount),
                ),
              _Step.error   => _ErrorStep(
                  key: const ValueKey('error'),
                  message: _errorMessage,
                  onRetry: () => setState(() => _step = _Step.amount),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _AmountStep extends StatelessWidget {
  final List<double> presets;
  final double? selectedAmount;
  final TextEditingController customController;
  final FocusNode customFocus;
  final bool isValid;
  final void Function(double) onSelectPreset;
  final void Function(String) onCustomChanged;
  final VoidCallback onConfirm;

  const _AmountStep({
    super.key,
    required this.presets,
    required this.selectedAmount,
    required this.customController,
    required this.customFocus,
    required this.isValid,
    required this.onSelectPreset,
    required this.onCustomChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recarregar carteira',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha ou digite o valor',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          // Presets
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3,
            children: presets.map((value) {
              final isSelected = selectedAmount == value;
              return GestureDetector(
                onTap: () => onSelectPreset(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A2340) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1A2340) : Colors.grey.shade200,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'R\$ ${value.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1A2340),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Campo customizado
          TextField(
            controller: customController,
            focusNode: customFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onCustomChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
            decoration: InputDecoration(
              hintText: 'Outro valor',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixText: 'R\$ ',
              prefixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2340)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Resumo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Valor selecionado', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                Text(
                  isValid ? 'R\$ ${selectedAmount!.toStringAsFixed(2).replaceAll('.', ',')}' : '—',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botão confirmar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isValid ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2340),
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Gerar QR Code PIX',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF1A2340), strokeWidth: 2.5),
          SizedBox(height: 20),
          Text(
            'Gerando QR Code...',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
          ),
          SizedBox(height: 4),
          Text(
            'Aguarde um momento',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _QrStep extends StatelessWidget {
  final double amount;
  final String pixKey;
  final String qrCodeBase64;
  final VoidCallback onCopy;
  final VoidCallback onBack;

  const _QrStep({
    super.key,
    required this.amount,
    required this.pixKey,
    required this.qrCodeBase64,
    required this.onCopy,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Remove o prefixo data:image/png;base64, se existir
    final base64Data = qrCodeBase64.contains(',')
        ? qrCodeBase64.split(',').last
        : qrCodeBase64;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1A2340)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pague via PIX',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
                  ),
                  Text(
                    'Escaneie o QR Code abaixo',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // QR Code
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(base64Data),
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Valor',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A2340)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Copia e cola
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código copia e cola', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                Text(
                  pixKey,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF1A2340), height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCopy,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Copiar código PIX',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'O saldo será creditado automaticamente após o pagamento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStep extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStep({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE53935)),
          const SizedBox(height: 16),
          const Text(
            'Erro ao gerar QR Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2340)),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
            ),
          ),
        ],
      ),
    );
  }
}