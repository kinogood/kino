TYPE-POOL ZGTSD .


*----------------------------------------------------------------------*
* 숫자 00~10.
CONSTANTS : ZGTSD_0(1)  VALUE '0',
            ZGTSD_1(1)  VALUE '1',
            ZGTSD_2(1)  VALUE '2',
            ZGTSD_3(1)  VALUE '3',
            ZGTSD_4(1)  VALUE '4',
            ZGTSD_5(1)  VALUE '5',
            ZGTSD_6(1)  VALUE '6',
            ZGTSD_7(1)  VALUE '7',
            ZGTSD_8(1)  VALUE '8',
            ZGTSD_9(1)  VALUE '9',
            ZGTSD_00(2) VALUE '00',
            ZGTSD_01(2) VALUE '01',
            ZGTSD_02(2) VALUE '02',
            ZGTSD_03(2) VALUE '03',
            ZGTSD_04(2) VALUE '04',
            ZGTSD_05(2) VALUE '05',
            ZGTSD_06(2) VALUE '06',
            ZGTSD_07(2) VALUE '07',
            ZGTSD_08(2) VALUE '08',
            ZGTSD_09(2) VALUE '09',
            ZGTSD_10(2) VALUE '10'.

*----------------------------------------------------------------------*
* 알파벳 A~Z
CONSTANTS : ZGTSD_A(1) VALUE 'A',
            ZGTSD_B(1) VALUE 'B',
            ZGTSD_C(1) VALUE 'C',
            ZGTSD_D(1) VALUE 'D',
            ZGTSD_E(1) VALUE 'E',
            ZGTSD_F(1) VALUE 'F',
            ZGTSD_G(1) VALUE 'G',
            ZGTSD_H(1) VALUE 'H',
            ZGTSD_I(1) VALUE 'I',
            ZGTSD_J(1) VALUE 'J',
            ZGTSD_K(1) VALUE 'K',
            ZGTSD_L(1) VALUE 'L',
            ZGTSD_M(1) VALUE 'M',
            ZGTSD_N(1) VALUE 'N',
            ZGTSD_O(1) VALUE 'O',
            ZGTSD_P(1) VALUE 'P',
            ZGTSD_Q(1) VALUE 'Q',
            ZGTSD_R(1) VALUE 'R',
            ZGTSD_S(1) VALUE 'S',
            ZGTSD_T(1) VALUE 'T',
            ZGTSD_U(1) VALUE 'U',
            ZGTSD_V(1) VALUE 'V',
            ZGTSD_W(1) VALUE 'W',
            ZGTSD_X(1) VALUE 'X',
            ZGTSD_Y(1) VALUE 'Y',
            ZGTSD_Z(1) VALUE 'Z'.


*----------------------------------------------------------------------*
* RANGE OPTION
CONSTANTS : ZGTSD_EQ(2)    VALUE 'EQ',
            ZGTSD_BT(2)    VALUE 'BT',
            ZGTSD_CP(2)    VALUE 'CP',
            ZGTSD_NE(2)    VALUE 'NE',

            " 숫자
            ZGTSD_000      TYPE CHAR3           VALUE '000',
            ZGTSD_0000     TYPE CHAR4           VALUE '0000',
            ZGTSD_0101     TYPE CHAR4           VALUE '0101',
            ZGTSD_99       TYPE CHAR2           VALUE '99',
            ZGTSD_20000101 TYPE DATUM           VALUE '20000101',
            ZGTSD_99991231 TYPE DATUM           VALUE '99991231',

            " 기호
            ZGTSD_COLON    TYPE CHAR1           VALUE ':',
            ZGTSD_SCOLON   TYPE CHAR1           VALUE ';', "Semi-Colon
            ZGTSD_PLUS     TYPE CHAR1           VALUE '+',
            ZGTSD_MINUS    TYPE CHAR1           VALUE '-',
            ZGTSD_UNDER    TYPE CHAR1           VALUE '_',
            ZGTSD_SLASH    TYPE CHAR1           VALUE '/',
            ZGTSD_BSLASH   TYPE CHAR1           VALUE '\',
            ZGTSD_PERCENT  TYPE CHAR1           VALUE '%',
            ZGTSD_STAR     TYPE CHAR1           VALUE '*',
            ZGTSD_Z_STAR   TYPE CHAR2           VALUE 'Z*',
            ZGTSD_SHARP    TYPE CHAR1           VALUE '#',
            ZGTSD_SB1      TYPE CHAR1           VALUE '[', "Square Brackets
            ZGTSD_SB2      TYPE CHAR1           VALUE ']', "Square Brackets
            ZGTSD_BR1      TYPE CHAR1           VALUE '(', "Brackets
            ZGTSD_BR2      TYPE CHAR1           VALUE ')', "Brackets
            ZGTSD_RBR1     TYPE CHAR2           VALUE `( `, "Brackets
            ZGTSD_RBR2     TYPE CHAR2           VALUE `) `, "Brackets
            ZGTSD_NA       TYPE CHAR3           VALUE 'N/A',
            ZGTSD_POINT    TYPE CHAR1           VALUE '.',
            ZGTSD_COMMA    TYPE CHAR1           VALUE ',',
            ZGTSD_QUOT     TYPE CHAR1           VALUE `'`,
            ZGTSD_SPACE    TYPE CHAR1           VALUE ` `,
            ZGTSD_FEEL     TYPE CHAR1           VALUE '!',
            ZGTSD_AT       TYPE CHAR1           VALUE '@'.

*----------------------------------------------------------------------*
*CODE

CONSTANTS : ZGTSD_EA          TYPE CHAR2           VALUE 'EA',
            ZGTSD_CRUD        TYPE CHAR4           VALUE 'CRUD',  "생성,조회,변경,삭제 Ind.
            ZGTSD_CRU         TYPE CHAR4           VALUE 'CRU',

            ZGTSD_LANG_KO     TYPE SPRAS           VALUE '3',
            ZGTSD_LANG_EN     TYPE SPRAS           VALUE 'E',
            ZGTSD_LANG_CN     TYPE SPRAS           VALUE '1',

            ZGTSD_CELLTAB     TYPE FIELDNAME       VALUE 'CELLTAB',
            ZGTSD_CELLCOL     TYPE FIELDNAME       VALUE 'CELLCOL',
            ZGTSD_LINECOL     TYPE FIELDNAME       VALUE 'LINECOL',

            " Data Type
            ZGTSD_DTYPE_CHAR  TYPE ATFOR           VALUE 'CHAR',
            ZGTSD_DTYPE_DATS  TYPE ATFOR           VALUE 'DATS',
            ZGTSD_DTYPE_DATE  TYPE ATFOR           VALUE 'DATE',
            ZGTSD_DTYPE_TIME  TYPE ATFOR           VALUE 'TIME',
            ZGTSD_DTYPE_NUM   TYPE ATFOR           VALUE 'NUM',
            ZGTSD_DTYPE_NUMC  TYPE ATFOR           VALUE 'NUMC',
            ZGTSD_DTYPE_UNIT  TYPE ATFOR           VALUE 'UNIT',
            ZGTSD_DTYPE_DEC   TYPE ATFOR           VALUE 'DEC',

            " 색상
            ZGTSD_COL_SKY     TYPE CHAR4           VALUE 'C100',
            ZGTSD_COL_BLUE    TYPE CHAR4           VALUE 'C400',
            ZGTSD_COL_BLUEX   TYPE CHAR4           VALUE 'C410',
            ZGTSD_COL_BLUEF   TYPE CHAR4           VALUE 'C401',
            ZGTSD_COL_GRAY    TYPE CHAR4           VALUE 'C200',
            ZGTSD_COL_GRAYX   TYPE CHAR4           VALUE 'C210',
            ZGTSD_COL_GRAYF   TYPE CHAR4           VALUE 'C201',
            ZGTSD_COL_YELLOW  TYPE CHAR4           VALUE 'C300',
            ZGTSD_COL_YELLOWX TYPE CHAR4           VALUE 'C310',
            ZGTSD_COL_GREEN   TYPE CHAR4           VALUE 'C500',
            ZGTSD_COL_GREENX  TYPE CHAR4           VALUE 'C510',
            ZGTSD_COL_GREENF  TYPE CHAR4           VALUE 'C501',
            ZGTSD_COL_RED     TYPE CHAR4           VALUE 'C600',
            ZGTSD_COL_REDX    TYPE CHAR4           VALUE 'C610',
            ZGTSD_COL_REDF    TYPE CHAR4           VALUE 'C601',
            ZGTSD_COL_ORANGE  TYPE CHAR4           VALUE 'C700',
            ZGTSD_COL_ORANGEX TYPE CHAR4           VALUE 'C710'.
