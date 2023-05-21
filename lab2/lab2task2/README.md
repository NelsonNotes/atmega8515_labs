# Задание 2

Две кнопки: одна включает светодиод с задержкой в 1 с, другая в 2 с. Реализовать на прерываниях INT0, INT1.

### Примечания:

- За глобальное разрешение прерываний отвечает флаг I регистра SREG.
- За INT0, INT1 соответственно отвечают биты PD2, PD3 порта D.
- Вывод производится в порт B.
- В регистр GICR устанавливается локальное разрешение конкретных прерываний.
- В MCUCR устанавливается режим срабатывания прерывания - по низкому уровню или по высокому.