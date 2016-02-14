#!/usr/bin/perl
# vim:set ts=4 sts=4 sw=4 tw=0:

use 5.010;
use strict;
use warnings;

use File::Basename;

#***********************************************************************#
#																		#
#	プログラム名：ドコモの開発に接触している単語ファイル内検索ツール.	#
#	ファイル名　：finderWords4docomo.pl									#
#	文字コード　：-														#
#	機能概要　　：業務を自宅に持ち帰らないこと前提であり,自宅で作業を	#
#				　しないことも前提のため開発現場で用いている単語を自宅	#
#				　PC内部から検索を掛けて削除させる(時間外作業).			#
#				　注意：アスキー文字のみ対応.							#
#	引数　　　　：開始：0												#
#	戻り値　　　：0⇒正常終了.											#
#				　非0⇒異常終了.										#
#																		#
#	動作例　　　：./finderWords4docomo.pl 0								#
#				　出力例：												#
#	事前作業　　：与えられた単語を取得しておくこと.						#
#				　https://infosec.nttdocomo.co.jp/wordfinder/index.htm	#
#																		#
#	作成者　　　：20160214　chesscommands								#
#	改版履歴　　：20160214　chesscommands　新規作成　R1.0				#
#																		#
#***********************************************************************#

my $SCRIPTNAME = basename($0, '');	# スクリプト自身の名前

# 引数チェック
my $prefix;
if ( 1 > @ARGV ) {
	print "引数に作業開始番号を指定してください.\n";
	print "\tUsage:$SCRIPTNAME 0\n";
	exit -1;	# 255として返却される.
}
elsif ( 1 == @ARGV && "0" eq $ARGV[0] ) {
	$prefix = $ARGV[0];
}
else {
	print "引数に作業開始番号を指定してください.\n";
	print "\t引数：0固定\n";
	print "\tUsage:$SCRIPTNAME 0\n";
	exit -1;	# 255として返却される.
}

# 実行時間の表示
sub subTimeClockArray()
{
	my @arrayTime = localtime();
	my $scalarTime;
	my @abbr = qw(1 2 3 4 5 6 7 8 9 10 11 12);
	my @week = qw(日 月 火 水 木 金 土);

	$arrayTime[0] = sprintf( "%02d", $arrayTime[0] );
	$arrayTime[1] = sprintf( "%02d", $arrayTime[1] );
	$arrayTime[4] = $abbr[$arrayTime[4]];
	$arrayTime[5] += 1900;
	$arrayTime[6] = $week[$arrayTime[6]];
	$scalarTime = $arrayTime[5] . "年 " . $arrayTime[4] . "月 " . $arrayTime[3] . "日 (" . $arrayTime[6] . ") " . $arrayTime[2] . ":" . $arrayTime[1] . ":" . $arrayTime[0];
	return $scalarTime;
}

#	検査指示
#アレア品川
#〒108-0075 東京都港区港南1丁目9−36
#	地図：https://goo.gl/maps/J9eMeRnyV112
#	私は15階での作業
my $text_docomoWord = <<'EOS';
MoBills
APL基盤
SUMMIT
RASCAL
L社
LM社
L環境
Ｍ環境
Ｊ環境
AOS
アクセスログ
顧シス
インシデント
ログイン
ShildWARE
CLINIC
BPR推進
ビジネス推進
ビジネス支援
開発推進
ALADIN統制
EOS

# サブ関数
sub subMainFindWord()
{
	my $ret = 0;

	# find 参考URL：https://hydrocul.github.io/wiki/commands/find.html
	# grep 参考URL：https://hydrocul.github.io/wiki/commands/grep.html
	`/usr/bin/find . -mount -type f -name "*" -perm -u=r -exec grep -Hn Mobills {} \\; 2>/dev/null 1>$SCRIPTNAME.log`;

	return $ret;
}

# サブ関数呼び出し
print "start $SCRIPTNAME " . &subTimeClockArray() . "\n";

&subMainFindWord( );
	# 表示されないorz
`/bin/cat $SCRIPTNAME.log`;

print "end   $SCRIPTNAME " . &subTimeClockArray() . "\n";

exit 0;

