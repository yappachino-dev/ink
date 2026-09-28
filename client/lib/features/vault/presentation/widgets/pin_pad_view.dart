import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/vault/domain/constants.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

const _buttonWidth = 70.0;
const _buttonHeight = 70.0;
const _buttonVSpacing = 16.0;
const _buttonHSpacing = 24.0;

class PinPadView extends StatelessWidget {
  const PinPadView({required this.pin, required this.onPinChanged, super.key});

  final String pin;
  final ValueChanged<String> onPinChanged;

  void _addDigit(String digit) {
    if (pin.length < maxPinLength) {
      onPinChanged(pin + digit);
    }
  }

  void _removeDigit() {
    if (pin.isNotEmpty) {
      onPinChanged(pin.substring(0, pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinDots(pin.length),

        const SizedBox(height: AppSpacing.xxxl),

        _Keypad(onDigitTap: _addDigit, onBackspaceTap: _removeDigit),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots(this.filledLength);

  final int filledLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxPinLength, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: AnimatedContainer(
            duration: AppDurations.base,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: index < filledLength
                  ? context.colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colorScheme.primary.withValues(
                  alpha: AppAlpha.medium,
                ),
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigitTap, required this.onBackspaceTap});

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeypadRow(digits: const ['1', '2', '3'], onTap: onDigitTap),
        const SizedBox(height: _buttonVSpacing),
        _KeypadRow(digits: const ['4', '5', '6'], onTap: onDigitTap),
        const SizedBox(height: _buttonVSpacing),
        _KeypadRow(digits: const ['7', '8', '9'], onTap: onDigitTap),
        const SizedBox(height: _buttonVSpacing),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: _buttonWidth),
            const SizedBox(width: _buttonHSpacing),
            _DigitKey(digit: '0', onTap: onDigitTap),
            const SizedBox(width: _buttonHSpacing),
            _BackspaceKey(onTap: onBackspaceTap),
          ],
        ),
      ],
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const _KeypadRow({required this.digits, required this.onTap});

  final List<String> digits;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DigitKey(digit: digits[0], onTap: onTap),
        const SizedBox(width: _buttonHSpacing),
        _DigitKey(digit: digits[1], onTap: onTap),
        const SizedBox(width: _buttonHSpacing),
        _DigitKey(digit: digits[2], onTap: onTap),
      ],
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final String digit;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.t.vault.methods.pin.keyPad.digitButton(n: digit),
      child: InkWell(
        onTap: () => onTap(digit),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: Center(
            child: Text(digit, style: context.textTheme.headlineMedium),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.t.vault.methods.pin.keyPad.backspaceButton,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: context.colorScheme.primary,
              size: AppSize.iconLarge,
            ),
          ),
        ),
      ),
    );
  }
}
