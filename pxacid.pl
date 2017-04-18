#!/usr/bin/perl
# pxacid.pl
#
use strict;
# plain XeTeX (�o�b�`���[�h)�̃R�}���h���C��
our $xetex = "xetex -interaction=batchmode";
# pltotf �̃R�}���h���C��
our $pltotf = "pltotf";
# opl2ofm �̃R�}���h���C��
our $opl2ofm = "opl2ofm";
# ovp2ovf �̃R�}���h���C��
our $ovp2ovf = "ovp2ovf";
# �J�[�j���O�̍ŏ��l(em�P��). �t�H���g���̃J�[�j���O�ł��̒l�����̂��̂�
# ���������.
our $min_kern = 0.01;
# ����̃X�����g�l. �X�����g�̂� SLANT �l�ɗp�����鑼, \XeTeXglyphbounds
# ���g���Ȃ��ꍇ�ɂ̓C�^���b�N�̂� SLANT �l�ɂ��p������.
our $std_slant = 0.167;
# �A��
our $gid_offset = 0;
#
use Data::Dump 'dump';
our $prog_name = "pxacid";
our $version = "0.2.4";
our $mod_date = "2013/01/04";
our $temp_base = "__$prog_name$$";

##-----------------------------------------------------------
## TeX �G���R�[�f�B���O�� Unicode �ʒu�Ƃ̑Ή�

use constant {
  XNAV => 0, XCWM => 1, XACC => 2, XBLW => 3, XLIN => 4,
  XCWC => 5, XCWA => 6
};
# �u�n�b�V���Q�ƒl�v�̍\��
# NAV : AJ1 �ł͕\���Ȃ�����
sub NAV () { { type => XNAV } }
# CWM : compound-word mark. �[����, x-�n�C�g�Ŏ��`�������Ȃ�����.
# VF �őΉ�����.
sub CWM () { { type => XCWM } }
# CWC : �L���b�v�n�C�g�� compound-word mark.
sub CWC () { { type => XCWC } }
# CWA : �A�Z���_�n�C�g�� compound-word mark.
sub CWA () { { type => XCWA } }
# ACC"ab" : ���� b �ɃA�N�Z���g a �� \accent �ō�����������.
sub ACC { { type => XACC, arg => clist(@_) } }
# BLW"ab" : ���� b �ɑ΂��P���ɃA�N�Z���g a ���d�˂�����.
# ���t�A�N�Z���g�̂��߂ɗp������.
sub BLW { { type => XBLW, arg => clist(@_) } }
# LIN"ab" : �P���ɕ��� a, b �����ɏo�͂������̂Ɠ���.
sub LIN { { type => XLIN, arg => clist(@_) } }
sub clist { [ map { ord($_) } (split(m//, $_[0])) ] }
sub zip { map { [$_[0][$_], $_[1][$_]] } (0..$#{$_[0]}) }

# tex2ucs �ŗp����. �G���R�[�f�B���O�� $enc, �����ʒu $tc ��
# �΂�, $tex2ucs_table{$enc}{$tc} �͑Ή����� Unicode �ʒu��\��.
# ������, �z��Q�ƂɂȂ��Ă���ꍇ��, �����̌����D�܂�������
# ���ׂ����̂�\��. (AJ1-4 �Ή��̃t�H���g�ňꕔ�̕�����������
# �₤���Ƃ�z��.) �܂�, �Ή��悪�������̓���Ȏw��̓n�b�V��
# �Q�Ƃŕ\����Ă���.
our $tex2ucs_table = {
'OT1' => [
# Greek uppercase
0x0393..0x0394,
0x0398,
0x039B,
0x039E,
0x03A0,
0x03A3,
0x03A5..0x03A6,
0x03A8..0x03A9,
# f-ligature
0xFB00..0xFB04,
# dotless
0x0131,
0x0237,
# accent
0x0060,
0x00B4,
0x02C7,
0x02D8,
0x00AF,
0x02DA,
0x00B8,
0x00DF,
0x00E6,
0x0153,
# non-English
0x00F8,
0x00C6,
0x0152,
0x00D8,
# lslash �̓��K�`���őΉ�����. ���̕����ʒu��L���ɂ���K�v������
# ����, ��肠���� CWM �����Ă���
CWM,
# quasi-ASCII
0x0021,
0x201D,
0x0023..0x0026,
0x2019,
0x0028..0x003B,
0x00A1,
0x003D,
0x00BF,
0x003F..0x005B,
0x201C,
0x005D,
0x02C6,
0x02D9,
0x2018,
0x0061..0x007A,
0x2013..0x2014,
0x02DD,
0x02DC,
0x00A8,
(undef) x 10,
0x0141,
(undef) x 31,
0x0142,
],
'T1'=>[
# accent
0x0060,
0x00B4,
0x02C6,
0x02DC,
0x00A8,
0x02DD,
0x02DA,
0x02C7,
0x02D8,
0x00AF,
0x02D9,
0x00B8,
0x02DB,
# punctuation
0x201A,
0x2039..0x203A,
0x201C..0x201E,
0x00AB,
0x00BB,
0x2013..0x2014,
CWM,
NAV, # 'perthousandzero'
# dotless
0x0131,
0x0237,
# f-ligature
0xFB00..0xFB04,
# quasi-ASCII
0x2423,
0x0021..0x0026,
0x2019,
0x0028..0x005F,
0x2018,
0x0061..0x007E,
0x002D, # 'hyphenchar'
# additional accented Latin
[0x0102,ACC"\x{2D8}A"],
0x0104,
[0x0106,ACC"\x{B4}C"],
[0x010C,ACC"\x{2C7}C"],
[0x010E,ACC"\x{2C7}D"],
[0x011A,ACC"\x{2C7}E"],
0x0118,
[0x011E,ACC"\x{2D8}G"],
[0x0139,ACC"\x{B4}L"],
[0x013D,LIN"L\x{2019}"],
0x0141,
[0x0143,ACC"\x{B4}N"],
[0x0147,ACC"\x{2C7}N"],
0x014A,
[0x0150,ACC"\x{2DD}O"],
[0x0154,ACC"\x{B4}R"],
[0x0158,ACC"\x{2C7}R"],
[0x015A,ACC"\x{B4}S"],
[0x0160,ACC"\x{2C7}S"],
[0x015E,BLW"\x{B8}S"],
[0x0164,ACC"\x{2C7}T"],
[0x0162,BLW"\x{B8}T"],
[0x0170,ACC"\x{2DD}U"],
[0x016E,ACC"\x{2DA}U"],
[0x0178,ACC"\x{A8}Y"],
[0x0179,ACC"\x{B8}Z"],
[0x017D,ACC"\x{2C7}Z"],
[0x017B,ACC"\x{2D9}Z"],
[0x0132,LIN"IJ"],
[0x0130,ACC"\x{2D9}I"],
0x0111,
0x00A7,
[0x0103,ACC"\x{2D8}a"],
0x0105,
[0x0107,ACC"\x{B4}c"],
[0x010D,ACC"\x{2C7}c"],
[0x010F,ACC"\x{2C7}d"],
[0x011B,ACC"\x{2C7}e"],
0x0119,
[0x011F,ACC"\x{2D8}g"],
[0x013A,ACC"\x{B4}l"],
[0x013E,LIN"l\x{2019}"],
0x0142,
[0x0144,ACC"\x{B4}n"],
[0x0148,ACC"\x{2C7}n"],
0x014B,
[0x0151,ACC"\x{2DD}o"],
[0x0155,ACC"\x{B4}r"],
[0x0159,ACC"\x{2C7}r"],
[0x015B,ACC"\x{B4}s"],
[0x0161,ACC"\x{2C7}s"],
[0x015F,BLW"\x{B8}s"],
[0x0165,ACC"\x{2C7}t"],
[0x0163,BLW"\x{B8}t"],
[0x0171,ACC"\x{2DD}u"],
[0x016F,ACC"\x{2DA}u"],
[0x00FF,ACC"\x{A8}y"],
[0x017A,ACC"\x{B8}z"],
[0x017E,ACC"\x{2C7}z"],
[0x017C,ACC"\x{2D9}z"],
[0x0133,LIN"ij"],
0x00A1,
0x00BF,
0x00A3,
# quasi-Latin-1
0x00C0..0x00D6,
0x0152,
0x00D8..0x00DE,
[LIN"SS"],
0x00E0..0x00F6,
0x0153,
0x00F8..0x00FE,
0x00DF,
],
'LY1'=>[
(undef),
0x20AC,
(undef)x 2,
0x2044,
0x02D9,
0x02DD,
0x02DB,
0xFB02,
(undef),
CWM,
0xFB00..0xFB01,
(undef),
0xFB03..0xFB04,
0x0131,
0x0237,
0x0060,
0x00B4,
0x02C7,
0x02D8,
0x00AF,
0x02DA,
0x00B8,
0x00DF,
0x00E6,
0x0153,
0x00F8,
0x00C6,
0x0152,
0x00D8,
0x0020..0x0026,
0x2019,
0x0028..0x005D,
0x02C6,
0x005F,
0x2018,
0x0061..0x007D,
0x02DC,
0x00A8,
0x0141,
0x0027,
0x201A,
0x0192,
0x201E,
0x2026,
0x2020..0x2021,
0x02C6,
0x2030,
0x0160,
0x2039,
0x0152,
0x017D,
0x005E,
0x2212,
0x0142,
0x2018..0x2019,
0x201C..0x201D,
0x2022,
0x2013..0x2014,
0x02DC,
0x2122,
0x0161,
0x203A,
0x0153,
0x017E,
0x007E,
0x0178,
0x00A0..0x00FF,
],
# �ّ̎�(variant)�̎戵�ɂ���:
# ��{�I��, ���̎��`�ƈقȂ邱�Ƃ��v�������ّ̎��ɂ��Ă�, ����
# ���`�ł̑�p�͍s��Ȃ�. �K�����������ł͂Ȃ��ꍇ��, ���̎��`��
# ���蓖�ĂĂ���.
'TS1' => [
(NAV) x 13, # �啶���p�A�N�Z���g�� AJ1 �ɂȂ�
NAV, # base straight single quote
(undef) x 4,
NAV, # base straight double quote
(undef) x 2,
NAV, # twelve u dash
NAV, # three-quarter em dash
CWC, # cap-height cwm
0x2190,
0x2192,
(NAV) x 4,
undef,
CWA, # ascender-height cwm
0x2422,
(undef) x 3,
0x0024,
(undef) x 2,
0x0027,
(undef) x 2,
0x204E, #2217
undef,
0x002C,
0x30A0,
0x002E,
0x2044,
(NAV) x 10, # olgstyle digits
(undef) x 2,
0x3008, # 2329
0x2212,
0x3009, # 232A
(undef) x 14,
0x2127,
(undef) x 1,
0x25EF,
(undef) x 1,
NAV, # Orogate
(undef) x 5,
0x2126,
(undef) x 3,
0x301A,
(undef) x 1,
0x301B,
0x2191,
0x2193,
0x0060,
(undef) x 1,
0x2605,
0x26AE,
0x271D,
(undef) x 7,
NAV, # leaf
0x26AD,
0x266A,
(undef) x 2,
NAV, # orogate
(undef) x 1,
0x017F,
(undef) x 10,
0x02F7,
0x30A0,
0x02DB,
0x02C7,
0x02DD,
NAV, # double grave
0x2020,
0x2021,
0x2016,
0x2030,
0x2022,
0x2103,
NAV, # dollar variant
NAV, # cent variant
0x0192, # florin
0x20A1,
0x20A9,
0x20A6,
0x20B2,
0x20B1,
0x20A4,
0x211E,
0x203D,
0x2E18,
0x20AB,
0x2122,
0x2031,
NAV, # paragraph sign variant
0x0E3F,
0x2116,
0x2052,
0x212E,
0x25E6, # 0x26AC
0x2120,
NAV, # quillbracketleft
NAV, # quillbracketright
0x00A2..0x00AA,
NAV, # copyleft
0x00AC,
0x2117,
0x00AE..0x00B7,
0x203B,
0x00B9..0x00BA,
0x221A,
0x00BC..0x00BE,
0x20AC,
(undef) x 22,
0x00D7,
(undef) x 31,
0x00F7,
(undef) x 9.
],
};
# �C�^���b�N�̏ꍇ�� $tex2ucs_table �̍���. (OT1 �̓V�F�[�v��
# ����Ĉꕔ�̕����ʒu�́u�����v���قȂ�.)
our $tex2ucs_ital_table = {
'OT1' => [
(undef) x 36,
0x00A3
],
};
# ���K�`�����. �����ł� TeX �G���R�[�f�B���O�̕����ʒu��p����.
our $ligature_table = {
'OT1' => [
[0x0B,0x69,0x0E],
[0x0B,0x6C,0x0F],
[0x21,0x60,0x3C],
[0x27,0x27,0x22],
[0x2D,0x2D,0x7B],
[0x3F,0x60,0x3E],
[0x60,0x60,0x5C],
[0x66,0x66,0x0B],
[0x66,0x69,0x0C],
[0x66,0x6C,0x0D],
[0x7B,0x2D,0x7C],
],
'T1' => [
[0x15,0x2D,0x16],
[0x1B,0x69,0x1E],
[0x1B,0x69,0x1F],
[0x21,0x60,0xBD],
[0x27,0x27,0x11],
[0x2C,0x2C,0x12],
[0x2D,0x2D,0x15],
[0x2D,0x7F,0x7F],
[0x3C,0x3C,0x13],
[0x3E,0x3E,0x14],
[0x3F,0x60,0xBE],
[0x60,0x60,0x10],
[0x66,0x66,0x1B],
[0x66,0x69,0x1C],
[0x66,0x6C,0x1D],
],
'LY1' => [
[0x0B,0x69,0x0E],
[0x0B,0x6C,0x0F],
[0x21,0x60,0xA1],
[0x21,0x91,0xA1],
[0x27,0x27,0x94],
[0x2C,0x2C,0x84],
[0x2D,0x2D,0x96],
[0x2D,0xAD,0xAD],
[0x3C,0x3C,0xAB],
[0x3E,0x3E,0xBB],
[0x3F,0x60,0xBF],
[0x3F,0x91,0xBF],
[0x60,0x60,0x93],
[0x66,0x66,0x0B],
[0x66,0x69,0x0C],
[0x66,0x6C,0x08],
[0x91,0x91,0x93],
[0x92,0x92,0x94],
[0x96,0x2D,0x97],
],
};

# tex2ucs($enc, $tc, $ital)
# TeX �G���R�[�f�B���O $enc �ł̕����ʒu $tc �̕����ɑΉ����� Unicode
# ����. �^�U�l $ital �̓C�^���b�N�w��.
sub tex2ucs {
  my ($enc, $tc, $ital) = @_;
  my $t = ($ital) ? $tex2ucs_ital_table->{$enc}[$tc] : undef;
  (defined $t) or $t = $tex2ucs_table->{$enc}[$tc];
  my @a = (ref $t eq 'ARRAY') ? (@$t) : ($t);
  return (wantarray) ? (@a) : $a[0];
}

##----------------------------------------------------------
## Unicode �ʒu���� AJ1 CID �ւ̑Ή�

# ucs2aj() �ŗp������e�[�u��. �l���z��Q�Ƃł�����̂�, ������
# �C�^���b�N�őΉ����قȂ���̂�\��.
our $ucs2aj_table = {
0x0020=>[1,9444],
0x0021=>[2,9445],
0x0022=>[3,9446],
0x0023=>[4,9447],
0x0024=>[5,9448],
0x0025=>[6,9449],
0x0026=>[7,9450],
0x0027=>[8,9451],
0x0028=>[9,9452],
0x0029=>[10,9453],
0x002A=>[11,9454],
0x002B=>[12,9455],
0x002C=>[13,9456],
0x002D=>[14,9457],
0x002E=>[15,9458],
0x002F=>[16,9459],
0x0030=>[17,9460],
0x0031=>[18,9461],
0x0032=>[19,9462],
0x0033=>[20,9463],
0x0034=>[21,9464],
0x0035=>[22,9465],
0x0036=>[23,9466],
0x0037=>[24,9467],
0x0038=>[25,9468],
0x0039=>[26,9469],
0x003A=>[27,9470],
0x003B=>[28,9471],
0x003C=>[29,9472],
0x003D=>[30,9473],
0x003E=>[31,9474],
0x003F=>[32,9475],
0x0040=>[33,9476],
0x0041=>[34,9477],
0x0042=>[35,9478],
0x0043=>[36,9479],
0x0044=>[37,9480],
0x0045=>[38,9481],
0x0046=>[39,9482],
0x0047=>[40,9483],
0x0048=>[41,9484],
0x0049=>[42,9485],
0x004A=>[43,9486],
0x004B=>[44,9487],
0x004C=>[45,9488],
0x004D=>[46,9489],
0x004E=>[47,9490],
0x004F=>[48,9491],
0x0050=>[49,9492],
0x0051=>[50,9493],
0x0052=>[51,9494],
0x0053=>[52,9495],
0x0054=>[53,9496],
0x0055=>[54,9497],
0x0056=>[55,9498],
0x0057=>[56,9499],
0x0058=>[57,9500],
0x0059=>[58,9501],
0x005A=>[59,9502],
0x005B=>[60,9503],
0x005C=>[97,9540],
0x005D=>[62,9505],
0x005E=>[63,9506],
0x005F=>[64,9507],
0x0060=>[65,9508],
0x0061=>[66,9509],
0x0062=>[67,9510],
0x0063=>[68,9511],
0x0064=>[69,9512],
0x0065=>[70,9513],
0x0066=>[71,9514],
0x0067=>[72,9515],
0x0068=>[73,9516],
0x0069=>[74,9517],
0x006A=>[75,9518],
0x006B=>[76,9519],
0x006C=>[77,9520],
0x006D=>[78,9521],
0x006E=>[79,9522],
0x006F=>[80,9523],
0x0070=>[81,9524],
0x0071=>[82,9525],
0x0072=>[83,9526],
0x0073=>[84,9527],
0x0074=>[85,9528],
0x0075=>[86,9529],
0x0076=>[87,9530],
0x0077=>[88,9531],
0x0078=>[89,9532],
0x0079=>[90,9533],
0x007A=>[91,9534],
0x007B=>[92,9535],
0x007C=>[99,9542],
0x007D=>[94,9537],
0x007E=>[100,9543],
0x00A0=>[1,9444],
0x00A1=>[101,9544],
0x00A2=>[102,9545],
0x00A3=>[103,9546],
0x00A4=>[107,9550],
0x00A5=>[61,9504],
0x00A6=>[93,9536],
0x00A7=>[106,9549],
0x00A8=>[132,9575],
0x00A9=>[152,9595],
0x00AA=>[140,9583],
0x00AB=>[109,9552],
0x00AC=>[153,9596],
0x00AD=>[151,9594],
0x00AE=>[154,9597],
0x00AF=>[129,9572],
0x00B0=>[155,9598],
0x00B1=>[156,9599],
0x00B2=>[157,9600],
0x00B3=>[158,9601],
0x00B4=>[127,9570],
0x00B5=>[159,9602],
0x00B6=>[118,9561],
0x00B7=>[117,9560],
0x00B8=>[134,9577],
0x00B9=>[160,9603],
0x00BA=>[144,9587],
0x00BB=>[123,9566],
0x00BC=>[161,9604],
0x00BD=>[162,9605],
0x00BE=>[163,9606],
0x00BF=>[126,9569],
0x00C0=>[164,9607],
0x00C1=>[165,9608],
0x00C2=>[166,9609],
0x00C3=>[167,9610],
0x00C4=>[168,9611],
0x00C5=>[169,9612],
0x00C6=>[139,9582],
0x00C7=>[170,9613],
0x00C8=>[171,9614],
0x00C9=>[172,9615],
0x00CA=>[173,9616],
0x00CB=>[174,9617],
0x00CC=>[175,9618],
0x00CD=>[176,9619],
0x00CE=>[177,9620],
0x00CF=>[178,9621],
0x00D0=>[179,9622],
0x00D1=>[180,9623],
0x00D2=>[181,9624],
0x00D3=>[182,9625],
0x00D4=>[183,9626],
0x00D5=>[184,9627],
0x00D6=>[185,9628],
0x00D7=>[186,9629],
0x00D8=>[142,9585],
0x00D9=>[187,9630],
0x00DA=>[188,9631],
0x00DB=>[189,9632],
0x00DC=>[190,9633],
0x00DD=>[191,9634],
0x00DE=>[192,9635],
0x00DF=>[150,9593],
0x00E0=>[193,9636],
0x00E1=>[194,9637],
0x00E2=>[195,9638],
0x00E3=>[196,9639],
0x00E4=>[197,9640],
0x00E5=>[198,9641],
0x00E6=>[145,9588],
0x00E7=>[199,9642],
0x00E8=>[200,9643],
0x00E9=>[201,9644],
0x00EA=>[202,9645],
0x00EB=>[203,9646],
0x00EC=>[204,9647],
0x00ED=>[205,9648],
0x00EE=>[206,9649],
0x00EF=>[207,9650],
0x00F0=>[208,9651],
0x00F1=>[209,9652],
0x00F2=>[210,9653],
0x00F3=>[211,9654],
0x00F4=>[212,9655],
0x00F5=>[213,9656],
0x00F6=>[214,9657],
0x00F7=>[215,9658],
0x00F8=>[148,9591],
0x00F9=>[216,9659],
0x00FA=>[217,9660],
0x00FB=>[218,9661],
0x00FC=>[219,9662],
0x00FD=>[220,9663],
0x00FE=>[221,9664],
0x00FF=>[222,9665],
0x0102=>[15756,15938],
0x0103=>[15769,15951],
0x0104=>[15737,15923],
0x0105=>[15745,15930],
0x0106=>[15758,15940],
0x0107=>[15771,15953],
0x010C=>[15759,15941],
0x010D=>[15772,15954],
0x010E=>[15761,15943],
0x010F=>[15774,15956],
0x0111=>[15775,15957],
0x0118=>[15760,15942],
0x0119=>[15773,15955],
0x011A=>[9395,9715],
0x011B=>[9407,9727],
0x011E=>[20335,20390],
0x011F=>[20355,20410],
0x0130=>[20338,20393],
0x0131=>[146,9589],
0x0132=>[20324,20379],
0x0133=>[20328,20383],
0x0139=>[15757,15939],
0x013A=>[15770,15952],
0x013D=>[15739,15924],
0x013E=>[15747,15931],
0x0141=>[141,9584],
0x0142=>[147,9590],
0x0143=>[15762,15944],
0x0144=>[15776,15958],
0x0147=>[15763,15945],
0x0148=>[15777,15959],
0x014A=>[20326,20381],
0x014B=>9436,
0x0150=>[15764,15946],
0x0151=>[15778,15960],
0x0152=>[143,9586],
0x0153=>[149,9592],
0x0154=>[15755,15937],
0x0155=>[15768,15950],
0x0158=>[15765,15947],
0x0159=>[15779,15961],
0x015A=>[15740,15925],
0x015B=>[15748,15932],
0x015E=>[15741,15926],
0x015F=>[15750,15933],
0x0160=>[223,9666],
0x0161=>[227,9670],
0x0162=>[15767,15949],
0x0163=>[15781,15963],
0x0164=>[15742,15927],
0x0165=>[15751,15934],
0x016E=>[9404,9724],
0x016F=>[9416,9736],
0x0170=>[15766,15948],
0x0171=>[15780,15962],
0x0178=>[224,9667],
0x0179=>[15743,15928],
0x017A=>[15752,15935],
0x017B=>[15744,15929],
0x017C=>[15754,15936],
0x017D=>[225,9668],
0x017E=>[229,9672],
0x0192=>[105,9548],
0x0237=>9435,
0x02C6=>[128,9571],
0x02C7=>[137,9580],
0x02D8=>[130,9573],
0x02D9=>[131,9574],
0x02DA=>[133,9576],
0x02DB=>[136,9579],
0x02DC=>[95,9538],
0x02DD=>[135,9578],
0x0393=>1013,# Greek letters
0x0394=>1014,# are available
0x0398=>1018,# only in fullwidth
0x039B=>1021,
0x039E=>1024,
0x03A0=>1026,
0x03A3=>1028,
0x03A5=>1030,
0x03A6=>1031,
0x03A8=>1033,
0x03A9=>1034,#9355=ohm sign
0x2013=>[114,9557],
0x2014=>[138,9581],
0x2016=>666,
0x2018=>[98,9541],
0x2019=>[96,9539],
0x201A=>[120,9563],
0x201C=>[108,9551],
0x201D=>[122,9565],
0x201E=>[121,9564],
0x2020=>[115,9558],
0x2021=>[116,9559],
0x2022=>[119,9562],
0x2026=>[124,9567],
0x2030=>[125,9568],
0x2039=>[110,9553],
0x203A=>[111,9554],
0x203B=>734,
0x2044=>[104,9547],
0x20AC=>[9354,9674],
0x2103=>710,
0x2116=>7610,
0x2122=>[228,9671],
0x2126=>9355,
0x2127=>15515,
0x212E=>20366,
0x2190=>737,
0x2191=>738,
0x2192=>736,
0x2193=>739,
0x2212=>[151,9594],
0x221A=>15499,
0x2423=>16272,
0x25E6=>12254,
0x25EF=>779,
0x2605=>722,
0x266A=>775,
0x3008=>682,
0x3009=>683,
0x30A0=>15516, #16205,
0xFB00=>[9358,9678],
0xFB01=>[112,9555],
0xFB02=>[113,9556],
0xFB03=>[9359,9679],
0xFB04=>[9360,9680],
};

## ucs2aj($uc, $it)
# Unicode �ʒu $uc �̕����ɑΉ����� AJ1 �� CID. $ital ���^�̏ꍇ��
# �C�^���b�N�̑Ή���p����.
sub ucs2aj {
  my ($uc, $ital) = @_;
  my $t = $ucs2aj_table->{$uc};
  my $aj = (ref $t) ? $t->[($ital) ? 1 : 0] : $t;
  return (defined $aj) ? ($aj + $gid_offset) : undef;
}

# �p�����ꂤ��S�Ă� Unicode �ʒu�̃��X�g.
our $target_ucs;
# �p�����ꂤ��S�Ă� AJ1 CID �l�̃��X�g.
our $target_aj;
sub gen_target_list {
  $target_ucs = [ sort { $a <=> $b } (keys %$ucs2aj_table) ];
  my %chk;
  foreach my $t (values %$ucs2aj_table) {
    foreach my $aj ((ref $t) ? @$t : $t) {
      $chk{$aj + $gid_offset} = 1;
    }
  }
  $target_aj = [ sort { $a <=> $b } (keys %chk) ];
}

# �ΏۂƂȂ� TeX �G���R�[�f�B���O�̃��X�g.
our $enc_list = [ keys %$tex2ucs_table ];

# �Ȃ�, ������ CID ����C�^���b�N�ւ̕ϊ��͎��̊֐��ōs����.
# �Q�l�Ƃ��ċL���Ă���.
sub to_italic {
  my ($u) = @_;
  return (1 <= $u && $u <= 230) ? ($u + 9444 - 1) :
    (9354 <= $u && $u <= 9417) ? ($u + 9674 - 9354) : 
    (15729 <= $u && $u <= 15794) ?
      (($u + 15915 - 15729) -
       (($u >= 15754) ? 4 : ($u >= 15750) ? 3 :
        ($u >= 15747) ? 2 : ($u >= 15739) ? 1 : 0)) :
    (20317 <= $u && $u <= 20385) ? ($u + 20372 - 20317) : 
    undef;
}

##----------------------------------------------------------
## �t�H���g�̃��g���b�N�f�[�^�� XeTeX ��p���Ď擾����

# get_metric($font, $chars)
# �t�H���g $font �̃��g���b�N���� XeTeX ��p���Ď擾��, �n�b�V����
# �i�[���ĕԂ�. $chars �͑ΏۂƂ��� Unicode �����̃��X�g(���͏��
# $target_ucs ���w�肵�Ă���).
sub get_metric {
  my ($font, $chars) = @_;
  # TeX�v���O�������t�@�C���ɏ����o���� XeTeX ���s
  write_whole("$temp_base.tex", query_xetex($font, $chars), 1);
  if (-s "$prog_name-save.log") {
    my $t = read_whole("$prog_name-save.log", 1);
    write_whole("$temp_base.log", $t, 1);
  } else {
    system "$xetex $temp_base";
  }
  (-s "$temp_base.log")
    or error("XeTeX execution failed");
  # ���O�ǂݍ���
  my $lin; my $par = {};
  open(my $hi, '<', "$temp_base.log")
    or error("cannot read file", "$temp_base.log");
  while ($lin = <$hi>) {
    if ($lin =~ m/^! /) {
      error("error occurred in XeTeX process");
    } elsif ($lin =~ m/^!OUT!(.*)$/) {
      nest_assign($par, $1);
    }
  }
  close($hi);
  # �h���p�����^
  derive_param($par);
  return $par;
}

# nest_assign($base, $text)
# $text �� "a:b:c=val" �̌`���̎��A$base->{a}{b}{c} �� val
# ��������. ������, val �� "XXXpt" (XXX �͎����l)�̌`����
# �ꍇ�� XXX / 10 (�f�U�C���T�C�Y 10pt �ɑ΂��鑊�Βl)�ɒu��
# ������. 
sub nest_assign {
  my ($base, $text) = @_;
  my ($pname, $value) = ($text =~ m/^(.*)=(.*)$/) or die;
  my @plist = split(m/:/, $pname);
  if ($value =~ m/^(-?\d+\.\d+)pt$/) {
    $value = $1 / 10;
  }
  nest_assign_sub($base, \@plist, $value);
}
sub nest_assign_sub {
  my ($hash, $plist, $value) = @_;
  my ($name, @plist1) = @$plist;
  if (!@plist1) {
    $hash->{$name} = $value;
  } else {
    (exists $hash->{$name}) or $hash->{$name} = {};
    nest_assign_sub($hash->{$name}, \@plist1, $value);
  }
}

# query_xetex($font, $chars)
# get_metric() �ŗp���� XeTeX �\�[�X�̓��e.
sub query_xetex {
  my ($font, $chars) = @_; my ($t);
  local $_ = <<'END';
%% �t�H���g��`
\font\fontU="[?FONT?]:-liga,+kern"
\font\fontI="[?FONT?]:-liga,+kern,+ital"
%% �ϐ���`
\newcount\cntA
\newcount\cntB
\newcount\cntC
\newcount\cntD
\newcount\cntI
\newcount\cntM
\newcount\cntN
\newdimen\dimA
\newdimen\dimB
\newdimen\dimC
\newbox\boxA
\newbox\boxB
%% �o�͏���
\def\debug#1{\immediate\write16{#1}}
\def\writeLog#1{\immediate\write-1{#1}}
\def\outData#1{\writeLog{!OUT!#1}}
%% �����l�̃��X�g
\def\doForEachUcs{?DO_UCS?}
\def\doForEachAj{?DO_AJ?}
%% \ifitalok: 'ital'���g���邩
\newif\ifitalok
\cntA="6C61746E %'latn'
\cntB="6974616C %'ital'
\cntM=\XeTeXOTcountfeatures\fontU \cntA 0
\cntI=0
\loop \ifnum\cntI<\cntM
  \cntC=\XeTeXOTfeaturetag\fontU \cntA 0 \cntI
  \ifnum\cntC=\cntB \italoktrue \fi
\advance\cntI 1 \repeat
\outData{italok=\ifitalok 1\else 0\fi}
%% �X�����g�l�̐���
\fontU
\ifx\XeTeXglyphbounds\undefined\else
\dimA=\XeTeXglyphbounds 3 ?129?\relax
\dimB=\XeTeXglyphbounds 3 ?9572?\relax
\advance\dimA-\dimB
\dimB=\XeTeXglyphbounds 2 ?129?\relax
\outData{slantx=\the\dimA}
\outData{slanty=\the\dimB}
\fi
%% Unicode �����ɑ΂���{���g���b�N���擾���o�͂���
%% \getMetric\<�t�H���g>{<�\���ړ���>}
\def\getMetric#1#2{%
  #1\def\pname{#2}%
  \let\do\doGetMetric \doForEachUcs}
\def\doGetMetric#1{%% {<Unicode�l>}
  \cntC=#1
  \iffontchar\font\cntC
    \outData{\pname:#1:wd=\the\fontcharwd\font\cntC}%
    \outData{\pname:#1:ht=\the\fontcharht\font\cntC}%
    \outData{\pname:#1:dp=\the\fontchardp\font\cntC}%
  \fi}
\getMetric\fontU{uup}
\ifitalok
\getMetric\fontI{uit}
\fi
%% �y�A�J�[�j���O�̒l���v�Z���o�͂���
%% \getKern\<�t�H���g>{<�\���ړ���>}
\def\getKern#1#2{%
  #1\def\pname{#2}%
  \let\do\doGetKernOuter \doForEachUcs}
\def\doGetKernOuter#1{%
  \cntC=#1
  \iffontchar\font\cntC
  {\let\do\doGetKernInner \doForEachUcs}\fi}
%% \XeTeXglyph �ł̏o�͂̊Ԃɂ̓J�[�j���O������Ȃ��̂�
%% �����ł� \char ���g��. ����� +ital �w��̃t�H���g�ł�
%% \fontcharwd �����������l��Ԃ��Ȃ�(-ital �̏ꍇ�̒l��
%% �Ȃ�)�̂�, ����������Ă���.
\def\doGetKernInner#1{%
  \cntD=#1
  \iffontchar\font\cntD
    \setbox\boxA=\hbox{\char\cntC}\dimA=\wd\boxA
    \setbox\boxA=\hbox{\char\cntD}\advance\dimA\wd\boxA
    \setbox\boxA=\hbox{\char\cntC\char\cntD}%
    \dimB=\wd\boxA \advance\dimB-\dimA
    \dimA=\dimB \ifdim\dimA<0pt \dimA=-\dimA \fi
    \ifdim\dimA<0.0001pt\else
      \outData{\pname:kern:\the\cntC:\the\cntD=\the\dimB}%
    \fi
  \fi}
\getKern\fontU{uup}
\ifitalok
\getKern\fontI{uit}
\fi
%% AJ1 �̊e�O���t�ɑ΂���{���g���b�N���擾���o�͂���
%% \getMetricAj\<�t�H���g>{<�\���ړ���>}
\def\getMetricAj#1#2{%
  #1\def\pname{#2}\cntM=\XeTeXcountglyphs\font
  \let\do\doGetMetricAj \doForEachAj}
\def\doGetMetricAj#1{%% {<Unicode�l>}
  \cntC=#1
  \ifnum\cntC<\cntM
    \setbox\boxA=\hbox{\XeTeXglyph\cntC}%
    \outData{\pname:#1:wd=\the\wd\boxA}%
    \outData{\pname:#1:ht=\the\ht\boxA}%
    \outData{\pname:#1:dp=\the\dp\boxA}%
  \fi}
\getMetricAj\fontU{aj}
%% �����܂�
\bye
END
  s/%%.*$/%/gm; s/\?FONT\?/$font/g;
  s/\?(\d+)\?/$1+$gid_offset/ge;
  $t = do_list($chars); s/\?DO_UCS\?/$t/g;
  $t = do_list($target_aj); s/\?DO_AJ\?/$t/g;
  return $_;
}

# do_list($vals)
# \do-���X�g�̍쐬. $vals �͔z��Q��.
sub do_list {
  my ($vals) = @_;
  return join("%\n", map { "\\do{$_}" } (@$vals));
}

# derive_param($par)
# XeTeX �Ŏ擾�������g���b�N������ɂ���, �h���p�����^(�Ⴆ��
# x-�n�C�g�̒l��)�����߂ăn�b�V���Ɋi�[����.
sub derive_param {
  my ($par) = @_; my ($cc);
  # xheight : x-�n�C�g(���ۂ� 'x' �̍�����p����)
  (defined($cc = ucs2aj(ord('x'))) &&
   defined($par->{xheight} = $par->{aj}{$cc}{ht}))
    or $par->{xheight} = 0.5;
  # capheight : �L���b�v�n�C�g(���ۂ� 'I' �̍�����p����)
  (defined($cc = ucs2aj(ord('I'))) &&
   defined($par->{capheight} = $par->{aj}{$cc}{ht}))
    or $par->{capheight} = 0.75;
  # ascheight : �A�Z���_�n�C�g(���ۂ� 'h' �̍�����p����)
  (defined($cc = ucs2aj(ord('h'))) &&
   defined($par->{ascheight} = $par->{aj}{$cc}{ht}))
    or $par->{ascheight} = 0.75;
  # space : �󔒕����̕�
  (defined($cc = ucs2aj(ord(' '))) &&
   defined($par->{space} = $par->{aj}{$cc}{wd}))
    or $par->{space} = 0.5;
  # slant : �C�^���b�N�̃X�����g
  my ($slx, $sly) = ($par->{slantx}, $par->{slanty});
  $par->{slant} = (defined $slx && defined $sly && $sly > 0) ?
    ($slx / $sly) : $std_slant;
}

##----------------------------------------------------------
## TeX ���g���b�N�t�@�C��(TFM/VF/OFM)�̍쐬

# �u�t�@�~�����v�� LaTeX �\�[�X���Ńt�@�~���w��ɗp�����镶�����
# pxacid �̑� 1 �����Ŏw�肳���.
# �u�t�@�~�����ʎq�v�̓��g���b�N�t�@�C���̖����ɗp�����镶�����
# --tfm-family �Ŏw�肳���. (--tfm-family ���Ȃ��ꍇ�́u�t�@�~�����v
# �Ɠ����ɂȂ�.)

# source_opl($par, $fam)
# AJ1 �G���R�[�f�B���O�� OPL (�������琶������� OFM �� VF �̎Q�Ɛ��
# �Ȃ�)���쐬����. $par �̓��g���b�N���, $fam �̓t�@�~����.
sub source_opl {
  my ($par, $fam) = @_;
  my @cnks = (<<"END");
(OFMLEVEL H 0)
(FAMILY $fam)
(CODINGSCHEME )
(FONTDIMEN
   (XHEIGHT R 1.0)
   (QUAD R 1.0)
   )
END
  my $paraj = $par->{aj};
  foreach my $cc (@$target_aj) {
    my $t = $paraj->{$cc};
    (defined $t) or next;
    my ($wd, $ht, $dp) = ($t->{wd}, $t->{ht}, $t->{dp});
    push(@cnks, <<"END");
(CHARACTER H @{[FH($cc)]}
   (CHARWD R @{[FR($wd)]})
   (CHARHT R @{[FR($ht)]})
   (CHARDP R @{[FR($dp)]})
   )
END
  }
  return join('', @cnks);
}
# source_virtual()
# TeX �G���R�[�f�B���O�p�̉��z�t�H���g�̂��߂̃\�[�X(PL �� OVP)��
# ��������. $par �̓��g���b�N���, $fam �̓t�@�~����, $ser �̓V���[�Y
# ��, $shp �̓V�F�[�v��, $enc �̓G���R�[�f�B���O, $tfmfam �̓t�@�~��
# ���ʎq.
sub source_virtual {
  my ($par, $fam, $ser, $shp, $enc, $tfmfam) = @_;
  my $ctchar = 0; my $ctkern = 0;
  my $ital = ($shp eq 'it') ? 1 : 0;

  # PL/OVP �� CHARACTER �L�q
  my (@pccnks, @vccnks, @valid);
  foreach my $tc (0 .. 255) {
    my @uc = tex2ucs($enc, $tc, $ital) or next;
    my $dat = resolve_map(\@uc, $par, $ital) or next;
    $valid[$tc] = 1; $ctchar += 1;
    my ($map, $wd, $ht, $dp) = @$dat;
    if (@$map) {
      $map = join("\n", map { "      $_" } (@$map));
      $map = "   (MAP\n$map\n      )";
    } else { $map = "   (MAP)"; }
    # OVP �L�q: CHARHT, CHARDP �� VF �ɂ͋L����Ȃ��̂ŏȂ�
    # (CHARWD �͈ꉞ�L�^����邪, dvipdfmx �ł͎g���Ȃ�)
    push(@vccnks, <<"END");
(CHARACTER H @{[FH($tc)]}
   (CHARWD R @{[FR($wd)]})
$map
   )
END
    # PL �L�q:
    push(@pccnks, <<"END");
(CHARACTER H @{[FH($tc)]}
   (CHARWD R @{[FR($wd)]})
   (CHARHT R @{[FR($ht)]})
   (CHARDP R @{[FR($dp)]})
   )
END
  }

  # ���K�`�������n�b�V���`���ɕϊ�
  my %lig;
  foreach my $ent (@{$ligature_table->{$enc}}) {
    $lig{$ent->[0]}{$ent->[1]} = $ent->[2];
  }

  # PL �� LIGTABLE �L�q
  my @lkcnks = ();
  {
    my $parkern = $par->{($ital) ? 'uit' : 'uup'}{kern};
    (defined $parkern) or last;
    foreach my $tc1 (0 .. 255) {
      ($valid[$tc1]) or next;
      my $uc1 = tex2ucs($enc, $tc1, $ital) or next;
      my $park1 = $parkern->{$uc1};
      my $lig1 = $lig{$tc1};
      (defined $park1 || defined $lig1) or next;
      my $ci = 0;
      push(@lkcnks, "(LABEL H @{[FH($tc1)]})");
      foreach my $tc2 (0 .. 255) {
        ($valid[$tc2]) or next;
        my $uc2 = tex2ucs($enc, $tc2, $ital);
        my $kern = (defined $uc2 && !ref $uc2) && $park1->{$uc2};
        my $ligres = $lig1->{$tc2};
        if (defined $ligres) {
          push(@lkcnks, "(LIG H @{[FH($tc2)]} H @{[FH($ligres)]})");
        } elsif (abs($kern) >= $min_kern) {
          push(@lkcnks, "(KRN H @{[FH($tc2)]} R @{[FR($kern)]})");
        } else { next; }
        $ci += 1;
      }
      if ($ci) { push(@lkcnks, "(STOP)"); }
      else { pop(@lkcnks); }
      $ctkern += $ci;
    }
  }
  @lkcnks = map { "   $_\n" } (@lkcnks);
  info("character count = $ctchar");
  info("lig/kern count = $ctkern");

  # OVP �L�q�̑S��
  # FONTDIMEN �w���, ��������� OFM ���g��Ȃ��̂Ŗ��Ӗ�
  my $shp1 = ($shp eq 'sl') ? 'sl' : 'n';
  my $ofmname = fontname($tfmfam, $ser, $shp1, 'J40');
  my $ovp = join('', <<"END", @vccnks);
(OFMLEVEL H 0)
(VTITLE $fam)
(FAMILY $fam)
(FONTDIMEN
   (QUAD R 1.0)
   (XHEIGHT R 1.0)
   )
(MAPFONT D 0
   (FONTNAME $ofmname)
   )
END

  # PL �L�q�̑S��
  my $space = $par->{space};
  my $xheight = $par->{xheight};
  my $slant = ($shp eq 'it') ? $par->{slant} : 
              ($shp eq 'sl') ? $std_slant : 0;
  my $pl = join('', <<"END1", @lkcnks, <<"END2", @pccnks);
(FAMILY $fam)
(FONTDIMEN
   (SLANT R @{[FR($slant)]})
   (SPACE R @{[FR($space)]})
   (STRETCH R @{[FR($space / 2)]})
   (SHRINK R @{[FR($space / 3)]})
   (XHEIGHT R @{[FR($xheight)]})
   (QUAD R 1.0)
   (EXTRASPACE R @{[FR($space / 3)]})
   )
(LIGTABLE
END1
   )
END2

  # ���ʂ̃e�L�X�g��Ԃ�
  return ($pl, $ovp);
}

sub resolve_map {
  my ($uclist, $par, $ital) = @_;
  my $paraj = $par->{aj};
  foreach my $uc (@$uclist) {
    if (!ref $uc) {
      my $cc = ucs2aj($uc, $ital) or next;
      my $t = $paraj->{$cc} or next;
      return [ [ "(SETCHAR H @{[FH($cc)]})" ],
               $t->{wd}, $t->{ht}, $t->{dp} ];
    } elsif ($uc->{type} == XNAV) {
      # AJ1 �ɑΉ����Ȃ�����
      return;
    } elsif ($uc->{type} == XCWM) {
      # CWM: x-�n�C�g�� compound-word mark
      return [ ["(MOVERIGHT R 0.0)"],
               0, $par->{xheight}, 0 ];
    } elsif ($uc->{type} == XCWC) {
      # CWC: �L���b�v�n�C�g�� compound-word mark
      return [ ["(MOVERIGHT R 0.0)"],
               0, $par->{capheight}, 0 ];
    } elsif ($uc->{type} == XCWA) {
      # CWA: �A�Z���_�n�C�g�� compound-word mark
      return [ ["(MOVERIGHT R 0.0)"],
               0, $par->{ascheight}, 0 ];
    } elsif ($uc->{type} == XACC) {
      # ACC: \accent �Ɠ��������ō���
      my $cc1 = ucs2aj($uc->{arg}[0], $ital) or next;
      my $cc2 = ucs2aj($uc->{arg}[1], $ital) or next;
      my $par1 = $paraj->{$cc1} or next;
      my $par2 = $paraj->{$cc2} or next;
      my $dx = ($par2->{wd} - $par1->{wd}) / 2;
      my $dy = $par2->{ht} - $par->{xheight};
      if ($dy < 0.01) { $dy = 0; }
      if ($ital) { $dx += $dy * $par->{slant}; }
      my @map = (
        "(PUSH)",
        "(SETCHAR H @{[FH($cc1)]})", "(POP)",
        "(SETCHAR H @{[FH($cc2)]})",
      );
      if ($dx != 0) {
        splice(@map, 1, 0, "(MOVERIGHT R @{[FR($dx)]})");
      }
      if ($dy != 0) {
        splice(@map, 1, 0, "(MOVEDOWN R @{[FR(-$dy)]})");
      }
      return [ \@map, $par2->{wd}, $par2->{ht}, $par2->{dp} ];
    } elsif ($uc->{type} == XBLW) {
      # BLW: �P���ɏd�˂č���
      my $cc1 = ucs2aj($uc->{arg}[0], $ital) or next;
      my $cc2 = ucs2aj($uc->{arg}[1], $ital) or next;
      my $par1 = $paraj->{$cc1} or next;
      my $par2 = $paraj->{$cc2} or next;
      my $len1 = ($par2->{wd} - $par1->{wd}) / 2;
      my @map = (
        "(PUSH)", "(MOVERIGHT R @{[FR($len1)]})",
        "(SETCHAR H @{[FH($cc1)]})", "(POP)",
        "(SETCHAR H @{[FH($cc2)]})",
      );
      return [ \@map, $par2->{wd}, $par2->{ht}, $par2->{dp} ];
    } elsif ($uc->{type} == XLIN) {
      # LIN: �P���ɕ��ׂč���
      my $cc1 = ucs2aj($uc->{arg}[0], $ital) or next;
      my $cc2 = ucs2aj($uc->{arg}[1], $ital) or next;
      my $par1 = $paraj->{$cc1} or next;
      my $par2 = $paraj->{$cc2} or next;
      my @map = (
        "(SETCHAR H @{[FH($cc1)]})",
        "(SETCHAR H @{[FH($cc2)]})",
      );
      my $len2 = $par->{kern}{$uc->{arg}[0]}{$uc->{arg}[1]};
      if (defined $len2) {
        splice(@map, 1, 0, $len2);
      }
      return [ \@map, $par1->{wd} + $par2->{wd},
               max($par1->{ht}, $par2->{ht}),
               max($par1->{dp}, $par2->{dp}) ];
    }
  }
  # ���̃t�H���g�ł͎g���Ȃ��ꍇ
  return;
}

# FR($value)
sub FR {
  local $_ = sprintf("%.7f", $_[0]); s/0+$/0/; return $_;
}
# FH($value)
sub FH {
  return sprintf("%X", $_[0]);
}

# use_berry($sw)
# Berry �K�����g�������w��. $sw �̓u�[���l.
# ���Ȃ݂Ɋ���̖����́uZR�K���v�ł��� ;-)
our $use_berry = 0;
sub use_berry { $use_berry = $_[0]; }

# NFSS �V���[�Y�� �� Berry �K�����ʎq
our $ser_kb = {
  l => 'l', m => 'r', b => 'b', bx => 'b', eb => 'x'
};
# NFSS �V�F�[�v�� �� Berry �K�����ʎq
our $shp_kb = {
  n => '', it => 'i', sl => 'o'
};
# LaTeX �G���R�[�f�B���O�� �� Berry �K�����ʎq
our $enc_kb = {
  'OT1' => '7t', 'T1' => '8t', 'TS1' => '8c', 'LY1' => '8y',
  'J40' => 'aj', # 'J40' �� AJ1 �̂���
};
# fontname($tfmfam, $ser, $shp, $enc)
# �w��̑����ɑ΂���t�H���g����Ԃ�. $tfmfam �̓t�@�~�����ʎq, $ser
# �̓V���[�Y��, $shp �̓V�F�[�v��, $enc �̓G���R�[�f�B���O��.
sub fontname {
  my ($tfmfam, $ser, $shp, $enc) = @_;
  $shp = $shp_kb->{$shp};
  $ser = $ser_kb->{$ser};
  if ($use_berry) {
    $enc = (exists $enc_kb->{$enc}) ? $enc_kb->{$enc} : lc($enc);
    return "$tfmfam$ser$shp$enc";
  } else {
    $enc = lc($enc);
    return "$tfmfam-$ser$shp-$enc";
  }
}

##----------------------------------------------------------
## LaTeX �t�H���g��`�t�@�C���̐���

# source_fd($fam, $ser, $enc, $tfmfam, $orgsrc)
# $fam �̓t�@�~��, $ser �̓V���[�Y, $enc �̓G���R�[�f�B���O, $tfmfam
# �̓t�H���g�����̃t�@�~�����ʎq, $orgsrc �͍X�V�O�̒�`�t�@�C��
# �̓��e(�ǉ����[�h�łȂ��ꍇ�͋�).
sub source_fd {
  my ($fam, $ser, $enc, $tfmfam, $orgsrc) = @_;
  # $spec{ser}{shp} �͌��݂� ser/shp �ɑ΂���t�H���g������\��.
  # ���������(ssub*)�̂��͖̂��� undef �����Ă���.
  # @pos �͐ݒ�̏������L�^���Ă���.
  my (%spec, @pos, $ser1, $shp1, $text);
  my $rx = qr/^\\DeclareFontShape\{$enc\}\{$fam\}
              \{(\w+)\}\{(\w+)\}\{<->(.*?)\}/x;
  foreach my $lin (split(m/\n/, $orgsrc)) {
    if (($ser1, $shp1, $text) = $lin =~ $rx) {
      push(@pos, "$ser1/$shp1");
      $spec{"$ser1/$shp1"} = ($text =~ m/^ssub\*/) ? undef : $text;
    }
  }
  # ���ݗL���Ȑݒ肪�Ȃ��ꍇ�ɂ͊���̏����l��^����
  # (m,b,bx �V���[�Y�� n,it,sl �V�F�[�v�̑g�ݍ��킹)
  if (!@pos) {
    foreach $ser1 ('m', 'b', 'bx') {
      foreach $shp1 ('n', 'it', 'sl') {
        push(@pos, "$ser1/$shp1"); $spec{"$ser1/$shp1"} = undef;
      }
    }
  }
  # �V�����V���[�Y��ǉ�
  foreach $shp1 ('n', 'it', 'sl') {
    if (!exists $spec{"$ser/$shp1"}) { push(@pos, "$ser/$shp1"); }
    $spec{"$ser/$shp1"} = fontname($tfmfam, $ser, $shp1, $enc);
  }
  #
#  foreach my $ent (@pos) {
#    ($ser1, $shp1) = $ent =~ m|^(.*)/(.*)$| or die;
#    info("$ser1/$shp1=" . $spec{$ent});
#  }
#  $ser1 = <STDIN>;
  # �{�[���h(b�܂���bx)�̃t�H���g�����݂��邩������.
  my $bfser;
  foreach my $ent (@pos) {
    (defined $spec{$ent}) or next;
    if ($ent =~ m|^bx?/|) { $bfser = 1; }
  }
  # �ȏ�̏�񂩂�V���� .fd �̓��e�����肷��.
  my (@cnks, $text);
  foreach my $ent (@pos) {
    ($ser1, $shp1) = $ent =~ m|^(.*)/(.*)$| or die;
    if (defined $spec{$ent}) {
      $text = $spec{$ent};
    } else {
      # �V���[�Y�̑��: b��bx�̈���݂̂�����ꍇ��, ����������ő��.
      # m���Ȃ��ꍇ�͍��ǉ������V���[�Y�ő��. ����ȊO��m�ő��.
      my $ser2 = ($ser1 eq 'm') ? $ser :
                 ($bfser && $ser1 eq 'b') ? 'bx' :
                 ($bfser && $ser1 eq 'bx') ? 'b' : 'm';
      $text = "ssub*$fam/$ser2/$shp1";
    }
    push(@cnks,
      "\\DeclareFontShape{$enc}{$fam}{$ser1}{$shp1}{<->$text}{}");
  }
  $text = join("\n", @cnks);
  # 
  my $fdname = lc("$enc$fam");
  return <<"END";
% $fdname.fd
\\DeclareFontFamily{$enc}{$fam}{}
$text
%% EOF
END
}

##----------------------------------------------------------
## dvipdfmx�p�̃}�b�v�t�@�C���쐬

# source_map($fam, $ser, $tfmfam, $font, $orgsrc)
# $fam �̓t�@�~��, $ser �̓V���[�Y, $tfmfam �̓t�H���g�����̃t�@�~��
# ���ʎq, $font �̓t�H���g�t�@�C����, $orgsrc �͍X�V�O�̃}�b�v�t�@�C��
# �̓��e(�ǉ����[�h�łȂ��ꍇ�͋�).
sub source_map {
  my ($fam, $ser, $tfmfam, $font, $orgsrc) = @_;
  my @spec;
  foreach my $lin (split(m/\n/, $orgsrc)) {
    if ($lin !~ m/^\s*(\#|$)/) {
      push(@spec, $lin);
    }
  }
  my $ofmname = fontname($tfmfam, $ser, 'n', 'J40');
  push(@spec, "$ofmname  Identity-H  $font");
  my $slofmname = fontname($tfmfam, $ser, 'sl', 'J40');
  push(@spec, "$slofmname  Identity-H  $font -s " . $std_slant);
  my $text = join("\n", @spec);
  return <<"END";
# pdfm-$fam.map
$text
# EOF
END
}

##----------------------------------------------------------
## LaTeX �X�^�C���t�@�C��

# source_style($font)
sub source_style {
  my ($fam) = @_; local ($_);
  $_ = <<'END';
% pxacid-?FAM?.sty
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{pxacid-?FAM?}
\DeclareRobustCommand*{\?FAM?family}{%
  \not@math@alphabet\?FAM?family\relax
  \fontfamily{?FAM?}\selectfont}
\DeclareTextFontCommand{\text?FAM?}{\?FAM?family}
% EOF
END
  s/\?FAM\?/$fam/g;
  return $_;
}

# source_test($fam, $ser)
sub source_test {
  my ($fam, $ser) = @_; local ($_);
  $_ = <<'END';
\documentclass[a4paper]{article}
\addtolength{\textheight}{6\baselineskip}
\addtolength{\topskip}{-3\baselineskip}
\AtBeginDvi{\special{pdf:mapfile pdfm-?FAM?}}
\usepackage[LY1,T1,OT1]{fontenc}
\usepackage{textcomp}
\usepackage{pxacid-?FAM?}
\newcommand*{\TestA}{\begin{quote}
?`But aren't Kafka's Schlo\ss\ and \AE sop's \OE uvres often na\"\i ve
vis-\`a-vis the d\ae monic ph\oe nix's official r\^ole
in fluffy soufll\'es?\end{quote}}
\newcommand*{\TestB}{\begin{quote}
\textyen 1,234 / \$56 / \pounds78 / \texteuro 90\end{quote}}
\begin{document}
\?FAM?family \fontseries{?SER?}\fontencoding{OT1}\selectfont
{\noindent\LARGE Family `?FAM?', Series `?SER?'}
\par\bigskip
\fontencoding{OT1}\selectfont
\upshape\noindent[Upright shape, OT1 encoding]\TestA\par
\itshape\noindent[Italic shape, OT1 encoding]\TestA\par
\slshape\noindent[Slanted shape, OT1 encoding]\TestA\par
\fontencoding{T1}\selectfont
\upshape\noindent[Upright shape, T1 encoding]\TestA\par
\itshape\noindent[Italic shape, T1 encoding]\TestA\par
\slshape\noindent[Slanted shape, T1 encoding]\TestA\par
\fontencoding{LY1}\selectfont
\upshape\noindent[Upright shape, LY1 encoding]\TestA\par
\itshape\noindent[Italic shape, LY1 encoding]\TestA\par
\slshape\noindent[Slanted shape, LY1 encoding]\TestA\par
\fontencoding{T1}\selectfont
\upshape\noindent[Upright shape, TS1 encoding]\TestB\par
\itshape\noindent[Italic shape, TS1 encoding]\TestB\par
\slshape\noindent[Slanted shape, TS1 encoding]\TestB\par
\end{document}
END
  s/\?FAM\?/$fam/g; s/\?SER\?/$ser/g;
  return $_;
}

##----------------------------------------------------------
## ���C��

# append_mode($value)
# �ǉ����[�h�� $value (�^�U�l)�ɐݒ肷��.
our $append_mode;
sub append_mode { $append_mode = $_[0]; }

# save_source($value)
# �\�[�X�ۑ����[�h�� $value (�^�U�l)�ɐݒ肷��.
our $save_source;
sub save_source { $save_source = $_[0]; }

# generate($font, $fam, $enclist)
sub generate {
  my ($font, $fam, $ser, $tfmfam) = @_;
  # XeTeX ��p���ă��g���b�N���𓾂�
  my $par = get_metric($font, $target_ucs);
  # AJ1 �� OFM ���쐬
  my $ofmname = fontname($tfmfam, $ser, 'n', 'J40');
  info("Process for $ofmname...");
  write_whole("$ofmname.opl", source_opl($par, $fam), 1);
  system("$opl2ofm $ofmname.opl $ofmname.ofm");
  (-s "$ofmname.ofm")
    or error("failed in converting OPL -> OFM", "$ofmname.ofm");
  if (!$save_source) { unlink("$ofmname.opl"); }
  # �X�����g�p�� OFM ���R�s�[
  my $slofmname = fontname($tfmfam, $ser, 'sl', 'J40');
  write_whole("$slofmname.ofm", read_whole("$ofmname.ofm", 1), 1);
  # �e�G���R�[�f�B���O�̉��z�t�H���g���쐬
  foreach my $enc ('OT1', 'T1', 'LY1', 'TS1') {
    # �e�V�F�[�v���Ƃ̏���
    foreach my $shp ('n', 'it', 'sl') {
      my $vfname = fontname($tfmfam, $ser, $shp, $enc);
      info("Process for $vfname...");
      my ($pl, $ovp) =
        source_virtual($par, $fam, $ser, $shp, $enc, $tfmfam);
      write_whole("$vfname.pl", $pl, 1);
      system("$pltotf $vfname.pl $vfname.tfm");
      (-s "$vfname.tfm")
        or error("failed in converting PL -> TFM", "$vfname.tfm");
      write_whole("$vfname.ovp", $ovp, 1);
      # �����Ő�������� OVF �� VF �Ƃ��Ďg��. OFM �͎̂Ă�.
      system("$ovp2ovf $vfname.ovp $vfname.ovf $temp_base.ofm");
      unlink("$vfname.vf"); rename("$vfname.ovf", "$vfname.vf");
      (-s "$vfname.vf")
        or error("failed in converting OPL -> VF", "$vfname.vf");
      if (!$save_source) { unlink("$vfname.pl", "$vfname.ovp"); }
    }
    # �t�H���g��`�t�@�C��
    my $fdname = lc("$enc$fam"); my $orgfd;
    if ($append_mode && -f "$fdname.fd") {
      $orgfd = read_whole("$fdname.fd");
    }
    my $fd = source_fd($fam, $ser, $enc, $tfmfam, $orgfd);
    write_whole("$fdname.fd", $fd);
  }
  # dvipdfmx �}�b�v�t�@�C��
  my $mapname = "pdfm-$fam"; my $orgmap;
  if ($append_mode && -f "$mapname.map") {
    $orgmap = read_whole("$mapname.map");
  }
  my $map = source_map($fam, $ser, $tfmfam, $font, $orgmap);
  write_whole("$mapname.map", $map);
  # LaTeX �X�^�C���t�@�C��
  my $styname = "pxacid-$fam";
  my $sty = source_style($fam);
  if (!$append_mode) { write_whole("$styname.sty", $sty); }
  my $texname = "pxacid-test-$fam-$ser";
  my $tex = source_test($fam, $ser);
  write_whole("$texname.tex", $tex);
}

#-----------------------------------------------------------

# main()
# ���C���v���V�[�W��.
sub main {
  my $prop = read_option();
  (defined $prop->{min_kern}) and $min_kern = $prop->{min_kern};
  (defined $prop->{std_slant}) and $std_slant = $prop->{std_slant};
  (defined $prop->{gid_offset}) and $gid_offset = $prop->{gid_offset};
  append_mode($prop->{append});
  use_berry($prop->{use_berry});
  save_source($prop->{save_source});
  save_log($prop->{save_log});
  gen_target_list();
  generate($prop->{font}, $prop->{family}, $prop->{series},
    $prop->{tfm_family});
}

# read_option()
# �R�}���h���C�������߂���. ���ʂ�1�̃n�b�V���Q�ƂƂ��ĕԂ����.
sub read_option {
  my $prop = {};
  if (!@ARGV) { show_usage(); exit; }
  while ($ARGV[0] =~ m/^-/) {
    my $opt = shift(@ARGV); my $arg;
    if ($opt =~ m/^--?h(elp)?/) {
      show_usage(); exit;
    } elsif ($opt eq '-a' || $opt eq '--append') {
      $prop->{append} = 1;
    } elsif ($opt eq '-b' || $opt eq '--use-berry') {
      $prop->{use_berry} = 1;
    } elsif ($opt eq '-s' || $opt eq '--save-source') {
      $prop->{save_source} = 1;
    } elsif ($opt eq '--save-log') {
      $prop->{save_log} = 1;
    } elsif (($arg) = $opt =~ m/^-(?:t|-tfm-family)(?:=(.*))?/) {
      (defined $arg) or $arg = shift(@ARGV);
      ($arg =~ m/^[a-z0-9]+$/) or error("bad family name", $arg);
      $prop->{tfm_family} = $arg;
    } elsif (($arg) = $opt =~ m/^--min-kern(?:=(.*))?/) {
      (defined $arg) or $arg = shift(@ARGV);
      ($arg =~ m/^[.0-9]+$/) or error("bad min-kern value", $arg);
      $prop->{min_kern} = $arg;
    } elsif (($arg) = $opt =~ m/^--slant(?:=(.*))?/) {
      (defined $arg) or $arg = shift(@ARGV);
      ($arg =~ m/^[.0-9]+$/ && 0 <= $arg && $arg <= 1)
        or error("bad slant value", $arg);
      $prop->{std_slant} = $arg;
    } elsif (($arg) = $opt =~ m/^--gid-offset(?:=(.*))?/) {
      (defined $arg) or $arg = shift(@ARGV);
      ($arg =~ m/^[0-9]+$/) or error("bad gid-offset value", $arg);
      $prop->{gid_offset} = $arg;
    } else {
      error("invalid option", $opt);
    }
  }
  ($#ARGV == 1) or error("wrong number of command arguments");
  my ($fam, $ser) = ($ARGV[0] =~ m|^(.*?)/(.*)$|) ?
       ($1, $2) : ($ARGV[0], 'm');
  ($fam =~ m/^[a-z]+$/) or error("bad family name", $fam);
  ($ser =~ m/^[a-z]+$/) or error("bad series name", $ser);
  (exists $ser_kb->{$ser}) or error("unknown series name", $ser);
  $prop->{family} = $fam; $prop->{series} = $ser;
  $prop->{font} = $ARGV[1];
  (defined $prop->{tfm_family})
    or $prop->{tfm_family} = $prop->{family};
  return $prop;
}

# show_usage()
# �g�p�@�̕\��.
sub show_usage {
  print <<"END";
This is $prog_name v$version <$mod_date> by 'ZR'.
Usage: $prog_name [<option>...] <family>[/<series>] <font_file>
  <family>    LaTeX family name to designate the font
  <series>    LaTeX series name to designate the font
  <font_file> file name of the target font (NOT font name); the file
              must be put in the location Kpathsea can find
Options are:
  -a / --append             append mode (for .fd & .map)
  -b / --use-berry          use Berry naming scheme
  -t / --tfm-family=<name>  font family name used in tfm names
  -s / --save-source        save PL/OPL/OVP files
       --min-kern=<val>     minimum kern to be employed
       --slant=<val>        slant value
       --gid-offset=<val>   offset between CID and GID
END
}

# info($msg, ...)
# ���b�Z�[�W��\��.
sub info {
  print STDERR (join(": ", $prog_name, @_), "\n");
}

# error($msg, ...)
# ���b�Z�[�W��\�����ăG���[�I������.
sub error {
  print STDERR (join(": ", $prog_name, @_), "\n");
  exit(-1);
}

# max($x, $y)
# $x �� $y �̂����傫������Ԃ�.
sub max {
  return ($_[0] > $_[1]) ? $_[0] : $_[1];
}

# save_log($value)
our $save_log;
sub save_log { $save_log = $_[0]; }

# write_whole($name, $dat, $bin)
# $name �̖��̃t�@�C���ɕ����� $dat �̓��e�������o��. �^�U�l
# $bin �̓o�C�i�����[�h�ݒ�.
sub write_whole {
  my ($name, $dat, $bin) = @_;
  open(my $ho, '>', $name)
    or error("cannot create file", $name);
  if ($bin) { binmode($ho); }
  print $ho ($dat);
  close($ho);
}

# read_whole($name, $bin)
# $name �̖��̃t�@�C���̓��e�𕶎���Ƃ��ĕԂ�. �^�U�l $bin ��
# �o�C�i�����[�h�ݒ�.
sub read_whole {
  my ($name, $bin) = @_; local ($/);
  open(my $hi, '<', $name)
    or error("cannot open file for input", $name);
  if ($bin) { binmode($hi); }
  my $dat = <$hi>;
  close($hi);
  return $dat;
}

# �I�����Ɏ��s����鏈��.
END {
  if ($save_log) {
    unlink("$prog_name-save.log");
    rename("$temp_base.log", "$prog_name-save.log");
  }
  # �ꎞ�t�@�C���̏���
  unlink("$temp_base.tex", "$temp_base.log", "$temp_base.ofm");
}

#-----------------------------------------------------------
main();
# EOF