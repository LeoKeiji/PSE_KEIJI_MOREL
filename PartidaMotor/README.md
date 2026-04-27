# Partida Estrela-Triângulo — Motor AC Trifásico
### Microcontrolador 8051 | Simulador EdSim51

> **Disciplina:** Projeto de Sistemas Embarcados para Engenharia Elétrica  
> **Curso:** Engenharia Elétrica e Engenharia de Comunicações — 5º ano  
> **Instituição:** IME — Seção de Engenharia Elétrica (SE/3)  
> **Período:** 2026.1 | **Professor:** Cap Fontenelle
> **Alunos** 1º Ten Keiji e 1º Ten Morel

---

## Sobre o Projeto

Este projeto implementa, em Assembly para o microcontrolador 8051, o controle de partida estrela-triângulo (Y-Δ) de um motor AC trifásico. A simulação é realizada no ambiente **EdSim51DI**.

O motor de referência utilizado é o **SEW-EURODRIVE DZ71K4** (0,15 kW / 380 V / 1680 RPM), e a estratégia de partida Y-Δ é empregada para reduzir a corrente de pico no acionamento, limitando-a a 1/3 da corrente de partida direta em triângulo.

---

## Arquivos do Repositório

```
├── partida_estrela_triangulo.asm   # Código Assembly principal
└── README.md                       # Este arquivo
```

---

## Como Usar no EdSim51

### 1. Abrir o simulador
Acesse [edsim51di.blogspot.com](https://edsim51di.blogspot.com) e abra o EdSim51DI.

### 2. Carregar o código
- Na aba **Editor**, apague o conteúdo padrão
- Cole o conteúdo de `partida_estrela_triangulo.asm`
- Clique em **Assemble** — deve aparecer `No errors`

### 3. Configurar as chaves de P2
Antes de executar, posicione as chaves conforme a função desejada:

| Chave | Pino | Função |
|-------|------|--------|
| SW0 | P2.0 | Bit 0 do tempo Y→Δ |
| SW1 | P2.1 | Bit 1 do tempo Y→Δ |
| SW2 | P2.2 | Bit 2 do tempo Y→Δ |
| SW3 | P2.3 | **START** — aciona o motor |
| SW4 | P2.4 | **REVERSE** — inverte sentido |

> As chaves SW0–SW2 formam um número binário de 3 bits que seleciona o tempo de permanência em estrela antes da comutação para triângulo.

### 4. Selecionar o tempo de comutação

| SW2 | SW1 | SW0 | Tempo Y |
|:---:|:---:|:---:|:-------:|
| 0 | 0 | 0 | 1 s |
| 0 | 0 | 1 | 2 s |
| 0 | 1 | 0 | 3 s |
| 0 | 1 | 1 | 4 s |
| 1 | 0 | 0 | 5 s |
| 1 | 0 | 1 | 6 s |
| 1 | 1 | 0 | 7 s |
| 1 | 1 | 1 | 8 s |

### 5. Executar
- Clique em **Run**
- Feche a chave **SW3** para acionar o motor
- Observe os LEDs de P1 conforme descrito abaixo

---

## Mapeamento de P1 — LEDs / Relés

> ⚠️ No EdSim51, os LEDs de P1 acendem com nível lógico **0** (lógica negada).

| LED | Pino | Relé | Estado aceso |
|-----|------|------|-------------|
| L0 | P1.0 | KM1 | Contator principal ligado |
| L1 | P1.1 | KM2 | Configuração estrela (Y) ativa |
| L2 | P1.2 | KM3 | Configuração triângulo (Δ) ativa |
| L3 | P1.3 | KM4 | Reversão de sentido ativa |

### Sequência normal de operação

```
Inicial:   L0 L1 L2 L3 — todos apagados (motor parado)
START:     L0 L1 acendem → motor parte em ESTRELA (Y)
Após T s:  L1 apaga, L2 acende → comuta para TRIÂNGULO (Δ)
REVERSE:   aguarda 3s → L1 acende, L3 acende → reversão em estrela
```

---

## Descrição do Código

### Estrutura geral

```
MAIN
 ├── Inicialização (P1, P2, Timer0, IE)
 ├── WAIT_START — aguarda SW3 fechado
 ├── Leitura do tempo via SW0-SW2
 ├── Liga motor em ESTRELA (P1 = FCH)
 └── MAIN_LOOP
      ├── Verifica flag R6 (tick de 1s)
      │    └── DJNZ R0 → comuta para TRIÂNGULO (P1 = FAH)
      └── CHECK_REV — verifica SW4
           └── WAIT_REV_TICK (3 ticks) → REVERSÃO (P1 = F6H)

TIMER0_ISR
 ├── Recarrega TH0/TL0 (20 ms)
 └── DJNZ R5 → a cada 50 disparos (1s): seta R6 = 1
```

### Valores de P1 (lógica negada)

| Estado | P1 (hex) | P1 (binário) | Relés ativos |
|--------|----------|--------------|--------------|
| Desligado | `FFH` | `1111 1111` | nenhum |
| Estrela | `FCH` | `1111 1100` | KM1 + KM2 |
| Triângulo | `FAH` | `1111 1010` | KM1 + KM3 |
| Reversão | `F6H` | `1111 0110` | KM1 + KM4 |

### Temporização (Timer0)

O Timer0 opera em **modo 1 (16 bits)**, recarregado a cada interrupção para gerar disparos de **20 ms**. O registrador `R5` conta 50 disparos consecutivos; ao atingir zero, a flag `R6` é setada, sinalizando que **1 segundo** se passou para o loop principal.

```
Recarga: TH0 = 3CH, TL0 = B0H  →  65536 - 15000 = 50536 (20ms @ 12MHz)
1 segundo = 50 × 20ms → DJNZ R5 partindo de 50
```

> O Timer0 é iniciado **uma única vez no início do programa** e nunca é parado, garantindo que a temporização funcione em qualquer ponto do código, inclusive durante a espera de reversão.

### Registradores utilizados

| Reg | Uso |
|-----|-----|
| `R0` | Segundos restantes em estrela (contagem regressiva) |
| `R1` | Contador dos 3 segundos de delay para reversão |
| `R2` | Estado atual: `0`=parado, `1`=estrela, `2`=triângulo |
| `R5` | Contador de ticks de 20ms (0–50) |
| `R6` | Flag de 1 segundo (setada pela ISR, consumida pelo loop) |

---

## Intertravamento

O código garante por software que **KM2 e KM3 nunca são acionados simultaneamente**, evitando curto-circuito entre as configurações estrela e triângulo. A transição sempre passa por `P1 = FFH` (tudo desligado) antes de energizar o próximo estado.

---

## Motor de Referência

| Parâmetro | Valor |
|-----------|-------|
| Modelo | SEW-EURODRIVE DZ71K4 |
| Potência | 0,15 kW |
| Tensão | 220 V (Δ) / 380 V (Y) |
| Corrente nominal | 1,06 A (Δ) / 0,61 A (Y) |
| Rotação | 1680 RPM |
| Ip / In | 3,5 |
| Frequência | 60 Hz |
| Proteção | IP 55 |
