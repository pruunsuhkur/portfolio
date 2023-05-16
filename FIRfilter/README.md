# Создание цифрового фильтра с конечной импульсной характеристикой

### Первый этап

Сначала с помощью онлайн инструмента для проектирования цифровых фильтров TFilter получим коэффициенты и порядок нашего фильтра, предварительно задав полосу частот, в которой он будет работать.
На рисунке ниже видны частоты, котиорые наш фильтр будет пропускать и разрядность коэффициентов для него = 16.

<div align="center">
    <figure >
    <img src=" screens/ACH.jpg" width="99%"/>
    <figcaption><center>Рисунок 1. АЧХ цифрового фильтра в TFilter.</center></figcaption>
    </figure>
</div>

Также в сервисе есть возможность посмотреть импульсную характеристику фильтра, что тоже представляет интерес.

<div align="center">
    <figure >
    <img src=" screens/IM.jpg" width="99%"/>
    <figcaption><center>Рисунок 2. Импульсная характеристика цифрового фильтра в TFilter.</center></figcaption>
    </figure>
</div>

### Второй этап

Для проектирования фильтра обратимся к ресурсам DSPedia и обнаружим, что существует по меньшей мере две возможности реализовать FIR фильтр.

<div align="center">
    <figure >
    <img src=" screens/simplearch.jpg" width="66%"/>
    <figcaption><center>Рисунок 3. Традиционная архитектура фильтра.</center></figcaption>
    </figure>
</div>

<div align="center">
    <figure >
    <img src=" screens/transversalarch.jpg" width="66%"/>
    <figcaption><center>Рисунок 4. Лучшая архитектура фильтра.</center></figcaption>
    </figure>
</div>

Реализуем обе и сравним полученные результаты, но сразу сделаем оговорку, все реализации фильтра будут рабочими, повторять много раз временные диаграммы лишено смысла, поэтому представим их в начале.

<div align="center">
    <figure >
    <img src=" screens/IMfact.jpg" width="99%"/>
    <figcaption><center>Рисунок 5. Импульсная характеристика цифрового фильтра.</center></figcaption>
    </figure>
</div>

<div align="center">
    <figure >
    <img src=" screens/ACHfact.jpg" width="99%"/>
    <figcaption><center>Рисунок 6. Реакция фильтра на синусоиду с линейно возрастающей частотой.</center></figcaption>
    </figure>
</div>

### Третий этап

Для создания простейшего цифрового фильтра нам потребуется всего лишь 2 always-блока в которых будет описано состояние сдвигового регистра и выходного регистра соответственно.
Код представлен ниже.

```verilog
module simplelfir(
	input wire signed [NUM_PRECISION   - 1 : 0] data, // входные данные будут знаковыми 16-разрядными
	input clk, reset,
	output reg signed [NUM_PRECISION*2 - 1 : 0] y 	); // выходные данные будут иметь в 2 раза большую разрядность
  
	parameter SRL_LENGTH 		= 27; // данный параметр характеризует порядок фильтра
	parameter NUM_PRECISION = 16; // данный параметр характеризует разрядность входных данных и коэффициентов

	reg  signed [0 : NUM_PRECISION - 1] dff   [SRL_LENGTH - 1 : 0]; // массив регистра сдвига
	wire signed [0 : NUM_PRECISION - 1] coeff [SRL_LENGTH - 1 : 0]; // массив проводов-коэффициентов

	integer i; // переменная для итерирования

	assign // присваивание коэффициентов в провода
				coeff[0]  = 272,
				coeff[1]  = 449,
				coeff[2]  = -266,
				...

	always @(posedge clk or posedge reset) // регистр сдвига будет с асинхронным сбросом
			if (reset) 
				for (i = 0; i < SRL_LENGTH; i = i + 1) 
					begin
						dff[i] <= {NUM_PRECISION{1'b0}}; // заполнение нулями по сигналу сброса
					end
			else 
				begin
					dff[0] <= data; // вход данных в нулевой регистр
					for (i = 0; i < SRL_LENGTH; i = i + 1) 
						begin
							dff[i + 1] <= dff[i]; // продвижение данных последовательно по регистрам 
						end
				end

		
		always @(posedge clk or posedge reset) // выходной регистр также будет с асинхронным сбросом
			if (reset) 
				y <= {NUM_PRECISION{1'b0}}; // заполнение нулями по сигналу сброса
			else 
				y <= (coeff[0] * dff[0]) + (coeff[1] * dff[1]) + (coeff[2] * dff[2]) + (coeff[3] * dff[3]) + (coeff[4] * dff[4]) + 
						 (coeff[5] * dff[5]) + (coeff[6] * dff[6]) + (coeff[7] * dff[7]) + (coeff[8] * dff[8]) + (coeff[9] * dff[9]) + 
						 (coeff[10] * dff[10]) + (coeff[11] * dff[11]) + (coeff[12] * dff[12]) + (coeff[13] * dff[13]) + (coeff[14] * dff[14]) + 
						 (coeff[15] * dff[15]) + (coeff[16] * dff[16]) + (coeff[17] * dff[17]) + (coeff[18] * dff[18]) + (coeff[19] * dff[19]) + 
						 (coeff[20] * dff[20]) + (coeff[21] * dff[21]) + (coeff[22] * dff[22]) + (coeff[23] * dff[23]) + (coeff[24] * dff[24]) + 
						 (coeff[25] * dff[25]) + (coeff[26] * dff[26]); // формирование отводов фильтра и их сумма
	
endmodule
```

Сразу становится понятно, что такая реализация будет иметь большой критический путь, далее мы в этом убедимся.
На рисунке приведена только часть схемы данного фильтра, видно, что регистры имеют асинхронный сброс и формируются отводы с коэфициентами фильтра.

<div align="center">
    <figure >
    <img src=" screens/simplertlasync.jpg" width="99%"/>
    <figcaption><center>Рисунок 7. RTL Shematic данного фильтра.</center></figcaption>
    </figure>
</div>

Создадим constraint-файл для просмотра критического пути данного фильтра.

```verilog
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
```

То есть будем проверять, заработает ли наш фильтр на тактовой частоте в 100 МГц. Делать мы это будем используя ZedBoard Zynq Evaluation and Development Kit (xc7z020clg484-1). 

<div align="center">
    <figure >
    <img src=" screens/simpleIDasyncslack.jpg" width="99%"/>
    <figcaption><center>Рисунок 8. Implemented Design простого фильтра с асинхронным сбросом.</center></figcaption>
    </figure>
</div>

Мы видим, что из-за цепочки умножений и сложений критический путь имеет огромную величину, это совершенно неудовлетворительно.
Utilization Report даёт следующую информацию:

```
1. Slice Logic
--------------

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs              |   16 |     0 |     53200 |  0.03 |
|   LUT as Logic          |   16 |     0 |     53200 |  0.03 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  433 |     0 |    106400 |  0.41 |
|   Register as Flip Flop |  433 |     0 |    106400 |  0.41 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 0     |          Yes |           - |          Set |
| 433   |          Yes |           - |        Reset |
| 0     |          Yes |         Set |            - |
| 0     |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+
```

Видно, что в имплеменитрованном дизайне фильтра используется 433 регистра с асинхронным сбросом.
Попробуем уменьшить использование ресурсов и сделать сброс синхронным.
Не будем приводить RTL Shematic и код модуля, так как они почти идентичны, посмотрим на имплементированный дизайн.

<div align="center">
    <figure >
    <img src=" screens/simpleIDsyncslack.jpg" width="99%"/>
    <figcaption><center>Рисунок 9. Implemented Design простого фильтра с синхронным сбросом.</center></figcaption>
    </figure>
</div>

Критический путь уменьшился, однако этого совершенно не достаточно для того, чтобы фильтр заработал на частоте в 100 МГц.
Посмотрим, что выдаёт Utilization Report на этот раз.

```
1. Slice Logic
--------------

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs              |    0 |     0 |     53200 |  0.00 |
|   LUT as Logic          |    0 |     0 |     53200 |  0.00 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  400 |     0 |    106400 |  0.38 |
|   Register as Flip Flop |  400 |     0 |    106400 |  0.38 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 0     |          Yes |           - |          Set |
| 0     |          Yes |           - |        Reset |
| 0     |          Yes |         Set |            - |
| 400   |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+
```

Интересно, что общее число используемых регистров уменьшилось до 400, при этом все они с синхронным сбросом.
Перейдём к реализации улучшенной архитектуры фильтра.

### Четвертый этап

В данной архитектуре будет всего лишь 1 always-блок, в котором будет описано поведение сдвигового регистра, однако появится блок generate, в котором будет описано умножение коэффициентов на входные данные.
Стоит отметить, что в такой реализации фльтра данные продвигаются от последнего регистра к первому, значит и умножаются на коэффициенты в обратном порядке.

```verilog
module transversalfir(
	input  wire signed [NUM_PRECISION   - 1 : 0] data, 
	input clk, reset,
	output wire signed [NUM_PRECISION*2 - 1 : 0] y 	); // выход не поменял разрядность, но стал проводом

	parameter SRL_LENGTH 		= 27;
	parameter NUM_PRECISION = 16;

	reg  signed [0 : NUM_PRECISION*2 - 1] dff   [SRL_LENGTH - 1 : 0]; // сдвиговый регистр увеличил разрядность
	wire signed [0 : NUM_PRECISION 	 - 1] coeff [SRL_LENGTH - 1 : 0]; // провода для загрузки коэффициентов не поменялись
	wire signed [0 : NUM_PRECISION*2 - 1] mult  [SRL_LENGTH - 1 : 0]; // добавились провода для формирования умножения коэффициентов на входные данные

	integer i;

	assign
				coeff[0]  = 272,
				coeff[1]  = 449,
				coeff[2]  = -266,
				...

	always @(posedge clk or posedge reset) // сначала посмотрим на асинхронный сброс
			if (reset) 
				for (i = 0; i < SRL_LENGTH; i = i + 1) 
					begin
						dff[i] <= {NUM_PRECISION{1'b0}};
					end
			else 
				begin
				  dff[SRL_LENGTH - 1] <= mult[SRL_LENGTH - 1]; // в последний регистр заходят данные, умноженные на последний коэффициент
					for (i = SRL_LENGTH - 2; i > -1; i = i - 1) // регистры идут в обратном порядке
						begin
							dff[i] <= dff[i + 1] + mult[i]; // в предыдущий регистр записывается значение суммы текущего и его отвода
						end
				end
	
	genvar gi; // переменная для генерации отводов
	generate // создание проводов с коэффициентами
	for (gi = SRL_LENGTH - 1; gi > -1; gi = gi - 1)  // итерируем опять же в обратном порядке
		begin
			assign mult[gi] = data * coeff[gi]; // делаем отводы
		end
	endgenerate
	
	assign y = dff[0]; // присваиваем выход нулевому регистру
	
endmodule
```

Стоит отметить, что в данной реализации синтезатор Vivado видит, что в конкретном фильтре используются симметричные коэффициенты, поэтому оптимизирует их использование и отводы с полученными данными подводятся сразу к двум регистрам.

<div align="center">
    <figure >
    <img src=" screens/transversalrtlasync.jpg" width="99%"/>
    <figcaption><center>Рисунок 10. RTL Shematic данного фильтра.</center></figcaption>
    </figure>
</div>

Посмотрим на имплементированный дизайн всё с теми же параметрами.

<div align="center">
    <figure >
    <img src=" screens/transversalIDasyncslack.jpg" width="99%"/>
    <figcaption><center>Рисунок 11. Implemented Design альтернативного фильтра с асинхронным сбросом.</center></figcaption>
    </figure>
</div>

Критический путь уменьшился практически в 20 раз, преимущество данной архитектуры уже очевидно.
Интересно, что схема имплеменитровалась по сути в 27 (порядок фильтра) DSP-блоков, выполняющих умножение и сложение.
Utilization Report на этот раз говорит следующее:

```
1. Slice Logic
--------------

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs              |   16 |     0 |     53200 |  0.03 |
|   LUT as Logic          |   16 |     0 |     53200 |  0.03 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |    1 |     0 |    106400 | <0.01 |
|   Register as Flip Flop |    1 |     0 |    106400 | <0.01 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 0     |          Yes |           - |          Set |
| 1     |          Yes |           - |        Reset |
| 0     |          Yes |         Set |            - |
| 0     |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+
```

Теперь в схеме всего лишь один регистр, действительно с асинхронным сбросом. 
Почему так мне понять не удалось. 
Можем предположить, что после изменения сброса на синхронный критический путь схемы уменьшится ещё на некторое значение.
Не будем приводить изменённый код модуля и RTL Schematic, они почти не отличаются, перейдём сразу к имплеменитрованному дизайну.

<div align="center">
    <figure >
    <img src=" screens/transversalIDsyncslack.jpg" width="99%"/>
    <figcaption><center>Рисунок 12. Implemented Design альтернативного фильтра с синхронным сбросом.</center></figcaption>
    </figure>
</div>

Полученная схема имеет миниммальный критический путь, всего лишь 0.48 нс, это в 5 раз лучше чем у версии с асинхронным сбросом - 2.399 нс.
Опять же, схема синтезировалась по сути только в DSP-блоки и Utilization Report это подтверждает.

```
1. Slice Logic
--------------

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs              |    0 |     0 |     53200 |  0.00 |
|   LUT as Logic          |    0 |     0 |     53200 |  0.00 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |    0 |     0 |    106400 |  0.00 |
|   Register as Flip Flop |    0 |     0 |    106400 |  0.00 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 0     |          Yes |           - |          Set |
| 0     |          Yes |           - |        Reset |
| 0     |          Yes |         Set |            - |
| 0     |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+
```

Теперь в схеме нет ни регистров, ни LUTов, это выглядит несколько странно, но промежуточный успех зафиксировать можно.
Post-Implementation Timing Simulation в данном проекте не проводилось.