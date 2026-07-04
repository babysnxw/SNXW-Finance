# Modelo de Dominio

Este documento define las entidades centrales del dominio financiero de SNXW Finance. El foco está en un aplicativo de finanzas personales, sin detalles de implementación.

## Income

**Propósito**
Representa el dinero que ingresa al usuario y que alimenta su flujo de caja.

**Propiedades principales**
- id
- source
- amount
- date
- recurrence
- notes

**Relaciones**
- Puede contribuir a uno o más budgets.
- Puede apoyar la ejecución de financial goals.
- Se analiza junto con expenses para evaluar el estado financiero.

## Expense

**Propósito**
Representa una salida de dinero realizada por el usuario.

**Propiedades principales**
- id
- category
- amount
- date
- recurrence
- notes
- isEssential

**Relaciones**
- Puede estar asociado a un budget.
- Afecta el flujo de caja y la capacidad de ahorro.
- Puede influir en financial goals.

## Debt

**Propósito**
Representa una obligación financiera que debe ser pagada en el tiempo.

**Propiedades principales**
- id
- name
- principal
- outstandingBalance
- interestRate
- minimumPayment
- dueDay
- status

**Relaciones**
- Puede tener una o varias installments.
- Puede recibir una o varias payments.
- Puede pertenecer opcionalmente a un CreditAccount.
- Puede representar un préstamo tradicional.

## CreditAccount

**Propósito**
Representa una cuenta de crédito con límite disponible y pagos periódicos.

**Propiedades principales**
- id
- issuer
- cardName
- creditLimit
- currentBalance
- minimumPayment
- closingDay
- dueDay

**Relaciones**
- Puede contener múltiples debts.
- Puede generar expenses cuando se realizan compras.
- Puede recibir payments aplicados al saldo.

## CashAccount

**Propósito**
Representa el dinero disponible en efectivo, tarjetas de débito o cuentas bancarias.

**Propiedades principales**
- id
- name
- type
- currentBalance
- currency

**Relaciones**
- Recibe income.
- Paga expenses.
- Realiza payments.

## Installment

**Propósito**
Representa una cuota programada dentro del pago de una deuda.

**Propiedades principales**
- id
- debtId
- installmentNumber
- amountDue
- dueDate
- paidDate
- status

**Relaciones**
- Pertenece a una debt.
- Puede ser cubierta por una payment.
- Ayuda a organizar deudas con calendario definido.

## Payment

**Propósito**
Representa un pago realizado para reducir o cancelar una obligación financiera.

**Propiedades principales**
- id
- amount
- date
- method
- reference
- sourceAccount
- targetId
- targetType

**Relaciones**
- Puede aplicarse a una debt, installment o credit account.
- Reduce saldos pendientes.
- Puede afectar el calendario de pagos futuros.

## Budget

**Propósito**
Representa un límite planificado de gasto para un período determinado.

**Propiedades principales**
- id
- period
- category
- plannedAmount
- spentAmount
- remainingAmount

**Relaciones**
- Se ve afectado por incomes y expenses.
- Puede apoyar el seguimiento de financial goals.
- Sirve como referencia para control financiero.

## Financial Goal

**Propósito**
Representa una meta financiera que el usuario desea alcanzar.

**Propiedades principales**
- id
- name
- targetAmount
- currentAmount
- deadline
- priority
- status

**Relaciones**
- Puede financiarse con incomes.
- Puede verse limitada por expenses y debts.
- Puede beneficiarse de budgets bien definidos.
