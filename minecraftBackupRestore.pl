#!/usr/bin/perl
# vim:set ts=4 sts=4 sw=4 tw=0:

use 5.010;
use strict;
use warnings;

#***********************************************************************#
#																		#
#	プログラム名：マインクラフトゲームのセーブデータを管理する.			#
#	ファイル名　：minecraftBackupRestore.pl								#
#	文字コード　：なし.													#
#	機能概要　　：マインクラフトゲームのセーブデータをバックアップ		#
#				　またはリストアを行う.									#
#	引数　　　　：第1引数：1 ⇒ バックアップ							#
#						　 2 ⇒ リストア								#
#				　第2引数：ファイル（バックアップまたはリストアの一覧）	#
#	戻り値　　　：0⇒正常終了.											#
#				　非0⇒異常終了.										#
#																		#
#	動作例　　　：./minecraftBackupRestore.pl 1 backup.txt				#
#				　出力ファイル：hoge20150705.tar.gz boo20150705.tar.gz	#
#	動作例　　　：./minecraftBackupRestore.pl 2 backup.txt				#
#				　出力ディレクトリ：hoge20150705/ boo20150705/			#
#																		#
#	作成者　　　：20150711　chesscommands								#
#	改版履歴　　：20150711　chesscommands　新規作成　R1.0				#
#				　20150830　chesscommands　タイムスタンプ判定追加　R1.1	#
#																		#
#***********************************************************************#

#	外部コマンドを用いて自分のファイル名を取得しているため,環境依存になっているはず.
my $myfileName = `basename $0`;
chomp $myfileName;

my $tarCommand = "/usr/bin/tar";
my $gzipCommand = "/usr/bin/gzip";
my $gunzipCommand = "/usr/bin/gunzip";
my $grepCommand = "/usr/bin/grep";
my $lsCommand = "/bin/ls";

# 引数チェック
if ( 2 != @ARGV ) {
	print "引数を指定してください.\n";
	print "Usage：$myfileName 1(or 2) hoge.txt\n";
	print "\t\t1：アーカイブ処理\n";
	print "\t\t2：展開処理\n";
	exit -1;
}

# 引数の確認
my $argvOne = $ARGV[0];
if ( 1 <= $argvOne and 2 >= $argvOne ) {
	#	問題なし.
}
else {
	print "第1引数に間違いがあります.\n";
	print "Usage：$myfileName 1(or 2) hoge.txt\n";
	exit -1;
}

# OSの種類を取得
my $osType = $^O;

my $saveDir;
my $homeDir = $ENV{"HOME"};

if ( "MSWin32" eq "$osType" ) {
	# WindowsOS
}
else {
	# その他OS
	$saveDir = "$homeDir/Library/Application Support/minecraft/saves";
}


# サブ関数
sub subStart()
{
	# 第2引数のファイルの存在を確認する.
	my $argvTwo = $ARGV[1];
	chomp $argvTwo;
	my $fileName = $argvTwo;

	#		完全にMacOS・LinuxOSに依存する...WindowsOSでは動かないだろう.
	if ( -f "./$argvTwo" ) {
		#	問題なし.
		$fileName = "./$argvTwo";
	}
	elsif ( -f "$homeDir/Desktop/$argvTwo" ) {
		#	問題なし.
		$fileName = "$homeDir/Desktop/$argvTwo";
	}
	elsif  ( -f $argvTwo ) {
		#	問題なし.
		$fileName = $argvTwo;
	}
	else {
		print "第2引数に間違いがあります.\n";
		print "Usage：$myfileName 1(or 2) $argvTwo\n";
		return -1;
	}
}

# サブ関数
sub subArgvArchiveFileOpen()
{
	my @file;
	my @outdir;
	my $fileName = $_[0];

	open(FILE, "<", $fileName) or die "$!";
	@file = <FILE>;
	close FILE;

	my $i = 0;
	foreach my $line ( @file ) {
		chomp $line;
		if ( -d "$saveDir/$line" ) {
			$outdir[$i] = "$saveDir/\t$line";
			$i++;
		}
		elsif ( $line =~ /^#.*/ ) {
			# スキップ.
		}
		else {
			# セーブデータが存在しないためスキップする.
			#continue;
		}
	}

	return @outdir;
}

# サブ関数
sub subArgvExtractFileOpen()
{
	my @file;
	my @tardir;
	my $fileName = $_[0];
	my $targzSavedir;
	$fileName =~ m|(.*/)(.+)$|m;
	$targzSavedir = $1;

	# ファイル内容を一括で読み込む.
	open(FILE, "<", $fileName) or die "$!";
	@file = <FILE>;
	close FILE;

	my $i = 0;
	foreach my $line ( @file ) {
		chomp $line;
		if ( -f "$targzSavedir$line.tar.gz" ) {
			$tardir[$i] = "$targzSavedir$line.tar.gz";
			$i++;
		}
		else {
			# セーブデータが存在しないためスキップする.
			#continue;
		}
	}

	if ( @tardir ) {
		# 展開ファイルあり.
	}
	else {
		print "展開ファイルがありません.\n";
		print "第2引数のファイルと同じ階層に配置してください.\n";
		exit -1;
	}

	return @tardir;
}

# サブ関数
sub subMainArchive()
{
	my @file = @_;
	my $count = @_;

	foreach my $line ( @file ) {
		$line =~ m:/(.*)\t(.*)$:;
		my $path = $1;
		my $filename = $2;
		#	アーカイブ
		my $desktopfile = "$homeDir/Desktop/$filename.tar.gz";
		if ( -f $desktopfile ) {
			#	すでにファイルが作成されている.
#			my $lsdesktopfile = system "$tarCommand", "-tvf", "$desktopfile";
			#	私はアホなのか.			戻り値は実行結果が返却されるだけで,コマンド結果（この場合は$tarCommand）ではない.
#			$lsdesktopfile =~ m|([d].*/$filename/$)|m;
#				これを教訓にするため,このコマンドを残しておく20150830

			my $lsdesktopfile = `$tarCommand -tvf $desktopfile | $grepCommand $filename/\$`;
			chomp $lsdesktopfile;
			my @ll4lsDesktopfile = split / +/,$lsdesktopfile;
			my $desktoptimefile = $ll4lsDesktopfile[5] . $ll4lsDesktopfile[6] . $ll4lsDesktopfile[7];

			my $lssavedirfile = `$lsCommand -dl '/${path}${filename}'`;
			chomp $lssavedirfile;
			my @ll4lsSavefile = split / +/,$lssavedirfile;
			my $savedirtimefile = $ll4lsSavefile[5] . $ll4lsSavefile[6] . $ll4lsSavefile[7];

			if ( $desktoptimefile eq $savedirtimefile ) {
				next;
				print "タイムスタンプ一致のためアーカイブ処理をスキップする.\n";
			}
			else {
#				print "アーカイブ処理を行う.\n";
			}
		}

		my $ret = system "$tarCommand", "-cf", "$homeDir/Desktop/$filename.tar", "-C/", "$path$filename";
		if ( $ret != 0 ) {
			print "tarコマンド実行時にエラーが発生しました.\n";
			exit $ret;
		}

		#	圧縮（同名上書き）
		system "$gzipCommand", "-f", "$homeDir/Desktop/$filename.tar";
	}

	return 0;
}

# サブ関数
sub subMainUnfolding()
{
	my @file = @_;
	my $count = @_;

	foreach my $line ( @file ) {
		$line =~ m:/(.*)\t(.*)$:m;
		my $path = $1;
		my $filename = $2;
		#	展開
		my $ret = system "$tarCommand", "-zxf", "$line", "-C", "$homeDir/Desktop/";
		if ( $ret != 0 ) {
			print "tarコマンド実行時にエラーが発生しました.\n";
			exit $ret;
		}
	}

	return 0;
}

# ------------------------------------------------------------

# サブ関数呼び出し
my @file;
my $ret = 9;

my $argFileName = &subStart();

if ( 1 == $argvOne ) {
	my @saveFile = &subArgvArchiveFileOpen( $argFileName );

	#	アーカイブ処理
	$ret = $#saveFile;
	$ret = &subMainArchive( @saveFile );
}
elsif ( 2 == $argvOne ) {
	my @targzFile = &subArgvExtractFileOpen( $argFileName );

	# 展開処理
	$ret = &subMainUnfolding( @targzFile );
}
else {
	$ret = -1;
}

exit $ret;


