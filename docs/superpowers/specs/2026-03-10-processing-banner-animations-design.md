# Processing Banner Animations Design

## Objetivo

Melhorar a UX do `ProcessingBanner` no perfil do jogador, transformando um componente estático em uma experiencia animada e fluida que transmite a sensacao de que as partidas estao sendo processadas ativamente.

## Mudancas

### 1. RotatingIcon
- Widget `StatefulWidget` com `SingleTickerProviderStateMixin`
- `AnimationController(duration: 1500ms)` com `repeat()`
- `AnimatedBuilder` + `Transform.rotate(angle: value * 2 * pi)`
- Rotacao continua no sentido horario

### 2. WaveText
- Widget `StatefulWidget` com `SingleTickerProviderStateMixin`
- Recebe uma `String` e renderiza cada caractere como widget individual em um `Row`
- Duracao da onda: `numChars * 50ms`
- Offset Y por caractere: `sin((progress * 2pi) - (index * 0.3)) * amplitude` dentro de um window ativo
- Amplitude: 3px (negativo no eixo Y)
- Ciclo: ao completar, espera 2 segundos e repete via `controller.addStatusListener` + `Future.delayed(2s)` + `controller.forward(from: 0)`
- Envolvido em `RepaintBoundary` para isolar repaints
- Caracteres usam `Transform.translate` (operacao de composicao, sem relayout)

### 3. AnimatedCounterBuilder
- Widget `StatefulWidget` com builder pattern
- Recebe `int target` e `Widget Function(BuildContext, int displayValue) builder`
- `didUpdateWidget` detecta mudanca no target
- `Timer.periodic(250ms)` incrementa `_displayValue++` com `setState`
- Cancela timer ao atingir o target
- Se novo target chega durante contagem: atualiza destino, timer continua
- Se novo target < displayValue (reset): pula direto pro novo valor

## Composicao Final

```
ProcessingBanner (StatelessWidget)
└── AnimatedCounterBuilder(
      target: status.matchesProcessed,
      builder: (context, displayValue) =>
        Row(
          RotatingIcon(icon: Icons.sync, size: 16),
          SizedBox(width: 8),
          WaveText(text: "Processando partidas... $displayValue/${status.matchesTotal}"),
        )
    )
```

## Arquivos

**Novos** (em `lib/features/player_profile/presentation/widgets/`):
- `rotating_icon.dart`
- `wave_text.dart`
- `animated_counter_builder.dart`

**Modificado:**
- `processing_banner.dart` — substitui conteudo estatico pela composicao dos 3 widgets

**Sem mudancas:**
- `PlayerProfileBloc` — continua poll a cada 3s normalmente

## Visual

- Faixa azul full-width, sem bordas arredondadas (mantido)
- Icone branco 16px girando
- Texto branco 12px w500 com efeito de onda
- Numeros contando sequencialmente a 250ms por incremento

## Animacoes Independentes

A onda e a contagem numerica operam de forma independente. A onda segue seu ciclo proprio (animar → esperar 2s → repetir) e a contagem reage apenas quando o BLoC emite um novo valor.
