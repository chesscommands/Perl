#!/usr/bin/perl
# vim:set ts=4 sts=4 sw=4 tw=0:

use 5.010;
use strict;
use warnings;

use File::Basename;

#***********************************************************************#
#																		#
#	プログラム名：ファイル名の先頭に連番を振る.							#
#	ファイル名　：filename2number.pl									#
#	文字コード　：-														#
#	機能概要　　：このツールが存在しているファイル名の先頭に,			#
#				　連番を割り振る.										#
#				　注意：サブディレクトリ配下は対象外.					#
#						変更前のファイルが存在しない場合強制終了する.	#
#						変更後のファイル名がすでに存在する場合上書く.	#
#						ファイルはいくつでも可.							#
#	引数　　　　：連番の開始番号を与える.								#
#				　嘆願：引数は数字										#
#	戻り値　　　：0⇒正常終了.											#
#				　非0⇒異常終了.										#
#																		#
#	動作例　　　：./filename2number.pl 3								#
#				　出力例：test1.txt ⇒ 3_test1.txt						#
#						　test2.txt ⇒ 4_test2.txt						#
#						　test3.txt ⇒ 5_test3.txt						#
#						　注意：区切り文字はアンダースコア				#
#																		#
#	作成者　　　：20160102　chesscommands								#
#	改版履歴　　：20160102　chesscommands　新規作成　R1.0				#
#																		#
#***********************************************************************#

my @startTimeEnd;	# 実行時間の格納
my $SCRIPTNAME = basename($0, '');

my $prefix;
if ( 1 < @ARGV ) {
	print "引数に連番用の割り振り開始番号を指定してください.\n";
	print "\tUsage:$SCRIPTNAME [開始番号]\n";
	exit -1;	# 255として返却される.
}
elsif ( 1 == @ARGV ) {
	$prefix = $ARGV[0];
}
else {
	$prefix = 1;
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

# サブ関数
sub subMainFilenameChangeAddNumber()
{
	my $ret = 0;

	# カレントディレクトリオープン
	opendir IN_DIR, '.' or die "$!";

	# 入力ディレクトリのファイル名を読み込む.
	while ( readdir ( IN_DIR )) {
		if ( /^$SCRIPTNAME$/ ) {
			next;
		}
		elsif ( -f && /^[^.]/ ) {
			print "変更前：$_\n";
			my $filename = $_;
			my $refilename = "${prefix}_$filename";
			print "\t\t$refilename\n";
#			rename ( $filename, $refilename );
#			変更前のファイルが存在しない時に,（強制終了せず）次のファイルに処理を移したい場合に上記の処理を有効にする（下記をコメントアウトする）.
			rename ( $filename, $refilename ) or die "$!";
		}
		else {
			next;
		}
		$prefix++;
	}

	# ディレクトリクローズ
	closedir IN_DIR;

	return $ret;
}

# サブ関数呼び出し
$startTimeEnd[0] = &subTimeClockArray();
print "start $startTimeEnd[0]\n";

&subMainFilenameChangeAddNumber( @ARGV );

$startTimeEnd[1] = &subTimeClockArray();
print "end $startTimeEnd[1]\n";

exit 0;

