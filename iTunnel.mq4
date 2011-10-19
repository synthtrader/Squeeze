#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Red


/* ������������ �� ������ */

/* ������� ����� */
double g_ibuf_92[];
double g_ibuf_100[];

/* ������ ����� */
double g_ibuf_96[];
double g_ibuf_104[];

/* ���� ��������� */
double tmp_arr_1[];
double tmp_arr_2[];
double tmp_arr_3[];
bool gi_120 = TRUE;

int init() {
   IndicatorBuffers(7);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, g_ibuf_92);

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, g_ibuf_96);

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, g_ibuf_100);

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, g_ibuf_104);

   SetIndexBuffer(4, tmp_arr_1);

   SetIndexBuffer(5, tmp_arr_2);
   SetIndexBuffer(6, tmp_arr_3);

   return (0);
}


int deinit() {
   return (0);
}


int start() {

   string ls_0;
   double some_atr_mojo;
   double ima_on_tmp_arr2;
   double ima_on_tmp_arr3;

   //������� ������� � ��� �������� �������������� �����
   int already_counted_bars = IndicatorCounted();
   if (already_counted_bars < 0) return (-1);
   if (already_counted_bars > 0) already_counted_bars--;
   int not_yet_counted_bars = Bars - already_counted_bars;

   //� ��� ������� �� ��� ��������� �����

   //� arr1 ��������� ������� ���������� ������� � �������� 17 �� ����� ��������
   for (int just_a_counter = not_yet_counted_bars - 1; just_a_counter >= 0; just_a_counter--) tmp_arr_1[just_a_counter] = iMA(NULL, 0, 17, 0, MODE_SMA, PRICE_CLOSE, just_a_counter);

   //� ������� arr2 � arr3 ����������� ������� �� ������� arr1 +/- �������� ATR
   for (just_a_counter = not_yet_counted_bars - 1; just_a_counter >= 0; just_a_counter--) {
      some_atr_mojo = 0.5 * iATR(NULL, 0, 17, just_a_counter);
      tmp_arr_2[just_a_counter] = iMAOnArray(tmp_arr_1, 0, 5, 0, MODE_SMA, just_a_counter) + some_atr_mojo;
      tmp_arr_3[just_a_counter] = iMAOnArray(tmp_arr_1, 0, 5, 0, MODE_SMA, just_a_counter) - some_atr_mojo;
   }

   //������� ��� ��� ���������� �������, �� ��� ��� ����������� ����������
   //������������ ������ ��� ��������� ����� �������
   for (just_a_counter = not_yet_counted_bars - 1; just_a_counter >= 0; just_a_counter--) {
      ima_on_tmp_arr2 = iMAOnArray(tmp_arr_2, 0, 10.0 * 0.5, 0, MODE_EMA, just_a_counter);
      ima_on_tmp_arr3 = iMAOnArray(tmp_arr_3, 0, 10.0 * 0.5, 0, MODE_EMA, just_a_counter);

      //�������� ��
      g_ibuf_92[just_a_counter] = EMPTY_VALUE;
      g_ibuf_100[just_a_counter] = EMPTY_VALUE;
      g_ibuf_96[just_a_counter] = EMPTY_VALUE;
      g_ibuf_104[just_a_counter] = EMPTY_VALUE;

      //���� �������� arr2 ������ ���� �� �����������, �� ����� � 92
      if (tmp_arr_2[just_a_counter] > ima_on_tmp_arr2) {
         g_ibuf_92[just_a_counter + 1] = tmp_arr_2[just_a_counter + 1];
         g_ibuf_92[just_a_counter] = tmp_arr_2[just_a_counter];
      }

      //���� �������� arr2 ������ ���� �� �����������, �� ����� � 100
      if (tmp_arr_2[just_a_counter] < ima_on_tmp_arr2) {
         g_ibuf_100[just_a_counter + 1] = tmp_arr_2[just_a_counter + 1];
         g_ibuf_100[just_a_counter] = tmp_arr_2[just_a_counter];
      }

      //�� �� � ��� �������� arr3
      if (tmp_arr_3[just_a_counter] > ima_on_tmp_arr3) {
         g_ibuf_96[just_a_counter + 1] = tmp_arr_3[just_a_counter + 1];
         g_ibuf_96[just_a_counter] = tmp_arr_3[just_a_counter];
      }
      if (tmp_arr_3[just_a_counter] < ima_on_tmp_arr3) {
         g_ibuf_104[just_a_counter + 1] = tmp_arr_3[just_a_counter + 1];
         g_ibuf_104[just_a_counter] = tmp_arr_3[just_a_counter];
      }
   }
   return (0);
}
