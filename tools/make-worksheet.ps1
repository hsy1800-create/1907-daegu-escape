param([string]$OutDir, [string]$ImgDir)
$ErrorActionPreference = 'Stop'

function RGBc($r, $g, $b) { return [int]($r + $g * 256 + $b * 65536) }
$DARK = RGBc 30 30 30; $YEL = RGBc 255 217 90; $PALE = RGBc 255 243 196; $GRAYT = RGBc 95 95 95; $LIGHT = RGBc 244 244 244
$LINEC = RGBc 190 190 190; $DECO = RGBc 230 225 218; $QM = RGBc 221 216 208; $WHITE = RGBc 255 255 255; $RED = RGBc 214 40 40
$FT = 'Jalnan 2'; $FB = 'Paperlogy 7 Bold'; $FM = 'Paperlogy 5 Medium'

function Set-Adj($shape, $val) {
  [void][System.__ComObject].InvokeMember('Item', [Reflection.BindingFlags]::SetProperty, $null, $shape.Adjustments, @(1, [single]$val))
}
function Add-Box($sl, $x, $y, $bw, $bh, $fill, $lineW = 2, $shadow = $true, $radius = 0.08) {
  $s = $sl.Shapes.AddShape(5, $x, $y, $bw, $bh)
  $mn = [Math]::Min($bw, $bh); Set-Adj $s ([Math]::Min(0.5, [Math]::Min(12.0, $mn / 3.0) / $mn))
  if ($fill -eq $null) { $s.Fill.Visible = 0 } else { $s.Fill.Visible = -1; $s.Fill.Solid(); $s.Fill.ForeColor.RGB = [int]$fill }
  if ($lineW -gt 0) { $s.Line.Visible = -1; $s.Line.ForeColor.RGB = $DARK; $s.Line.Weight = [single]$lineW } else { $s.Line.Visible = 0 }
  if ($shadow) { $s.Shadow.Visible = -1; $s.Shadow.OffsetX = 3.5; $s.Shadow.OffsetY = 3.5; $s.Shadow.Blur = 0; $s.Shadow.ForeColor.RGB = $DARK; $s.Shadow.Transparency = 0 } else { $s.Shadow.Visible = 0 }
  $s.TextFrame.TextRange.Text = ''
  return $s
}
function Set-Font($tr, $font, $size, $color, $align = 1) {
  $tr.Font.Name = [string]$font; $tr.Font.NameFarEast = [string]$font; $tr.Font.Size = [single]$size; $tr.Font.Color.RGB = [int]$color
  $tr.ParagraphFormat.Alignment = [int]$align; try { $tr.ParagraphFormat.WordWrap = -1 } catch {}
}
function Add-Text($sl, $x, $y, $tw, $th, $text, $font = $FM, $size = 11, $color = $DARK, $align = 1, $anchor = 1) {
  $t = $sl.Shapes.AddTextbox(1, $x, $y, $tw, $th)
  $tf = $t.TextFrame; $tf.WordWrap = -1; $tf.AutoSize = 0
  $tf.MarginLeft = 0; $tf.MarginRight = 0; $tf.MarginTop = 0; $tf.MarginBottom = 0; $tf.VerticalAnchor = [int]$anchor
  $tf.TextRange.Text = $text
  Set-Font $tf.TextRange $font $size $color $align
  $t.Left = [single]$x; $t.Top = [single]$y; $t.Width = [single]$tw; $t.Height = [single]$th
  return $t
}
function Add-Circle($sl, $x, $y, $d, $label, $fill = $YEL, $size = 13) {
  $s = $sl.Shapes.AddShape(9, $x, $y, $d, $d)
  $s.Fill.Solid(); $s.Fill.ForeColor.RGB = [int]$fill; $s.Line.ForeColor.RGB = $DARK; $s.Line.Weight = 2; $s.Shadow.Visible = 0
  $tf = $s.TextFrame; $tf.MarginLeft = 0; $tf.MarginRight = 0; $tf.MarginTop = 0; $tf.MarginBottom = 0; $tf.WordWrap = 0; $tf.VerticalAnchor = 3
  $tf.TextRange.Text = $label; Set-Font $tf.TextRange $FT $size $DARK 2
  return $s
}
function Add-Chip($sl, $x, $y, $cw, $label) {
  $s = $sl.Shapes.AddShape(5, $x, $y, $cw, 22); Set-Adj $s 0.5
  $s.Fill.Solid(); $s.Fill.ForeColor.RGB = $DARK; $s.Line.Visible = 0; $s.Shadow.Visible = 0
  $tf = $s.TextFrame; $tf.MarginLeft = 4; $tf.MarginRight = 4; $tf.MarginTop = 0; $tf.MarginBottom = 0; $tf.VerticalAnchor = 3
  $tf.TextRange.Text = $label; Set-Font $tf.TextRange $FB 9.5 $WHITE 2
}
function Add-Line($sl, $x1, $y1, $x2, $y2, $color = $LINEC, $lw = 1) {
  $l = $sl.Shapes.AddLine($x1, $y1, $x2, $y2); $l.Line.ForeColor.RGB = [int]$color; $l.Line.Weight = [single]$lw
}
function Add-Title($sl, $partA, $partB) {
  $t = Add-Text $sl 28 52 520 40 ($partA + $partB) $FT 30 $DARK
  $r = $t.TextFrame2.TextRange.Characters($partA.Length + 1, $partB.Length)
  $r.Font.Fill.ForeColor.RGB = $YEL; $r.Font.Line.Visible = -1; $r.Font.Line.ForeColor.RGB = $DARK; $r.Font.Line.Weight = 1.6
}
function Add-Deco($sl) {
  $o = $sl.Shapes.AddShape(9, 470, -60, 175, 175); $o.Fill.Visible = 0; $o.Line.ForeColor.RGB = $DECO; $o.Line.Weight = 5; $o.Shadow.Visible = 0
  [void](Add-Text $sl 520 4 60 60 '?' $FT 46 $QM 2)
}
function Add-CardHead($sl, $y, $num, $title, $hint) {
  [void](Add-Circle $sl 42 ($y + 12) 26 $num)
  [void](Add-Text $sl 76 ($y + 14) 260 24 $title $FT 16 $DARK)
  if ($hint) { [void](Add-Text $sl 300 ($y + 18) 250 16 $hint $FM 9.5 $GRAYT 3) }
}
function Add-Photo($sl, $file, $bx, $by, $bw, $bh) {
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile($file); $iw = $img.Width; $ih = $img.Height; $img.Dispose()
  $sc = [Math]::Min($bw / $iw, $bh / $ih); $pw2 = $iw * $sc; $ph2 = $ih * $sc
  $p = $sl.Shapes.AddPicture($file, 0, -1, $bx + ($bw - $pw2) / 2, $by + ($bh - $ph2) / 2, $pw2, $ph2)
  return $p
}
function Add-Footer($sl, $text) { [void](Add-Text $sl 28 824 539 12 $text $FM 7.5 $GRAYT 2) }

$pp = New-Object -ComObject PowerPoint.Application
$pres = $pp.Presentations.Add(0)
$pres.PageSetup.SlideWidth = 595.25; $pres.PageSetup.SlideHeight = 841.875

# ======================= page 1: student front =======================
$s1 = $pres.Slides.Add(1, 12)
Add-Deco $s1
Add-Chip $s1 28 28 104 '내 탐정 수첩 앞면'
Add-Title $s1 '1907 대구 ' '방탈출'
[void](Add-Text $s1 28 96 540 16 '태블릿을 보며 써요. 내 미션을 풀고, 친구에게 물어 의연금을 모아요!' $FM 11 $GRAYT)

[void](Add-Box $s1 28 122 539 44 $WHITE)
[void](Add-Text $s1 44 136 40 18 '이름' $FB 12)
[void](Add-Box $s1 78 131 130 26 $PALE 1.5 $false)
[void](Add-Text $s1 224 136 40 18 '번호' $FB 12)
[void](Add-Box $s1 258 131 52 26 $PALE 1.5 $false)
[void](Add-Text $s1 330 136 225 18 '(        )모둠   (        )째 탐정' $FB 12)

# card 1: my mission
[void](Add-Box $s1 28 178 539 246 $WHITE)
Add-CardHead $s1 178 '1' '내 미션' '태블릿에 나온 내 미션에 ○ 해요'
$titles = @('광문사의 꿈', '운동의 시작', '서상돈의 계산', '남일동 부인들', '대구시민의 날')
$files = @('m1-gwangmunsa-sign.jpg', 'm2-gwangmunsa-site.jpg', 'm3-seo-sangdon.jpg', 'm4-roster.jpg', 'm5-park.jpg')
for ($i = 0; $i -lt 5; $i++) {
  $sx = 42 + $i * 103.5
  [void](Add-Box $s1 $sx 220 97 88 $LIGHT 1.2 $false)
  [void](Add-Photo $s1 (Join-Path $ImgDir $files[$i]) ($sx + 4) 224 89 60)
  [void](Add-Text $s1 $sx 289 97 14 ('미션 ' + ($i + 1) + ' ' + $titles[$i]) $FB 8.5 $DARK 2)
}
[void](Add-Text $s1 44 326 90 18 '내 질문의 답' $FB 12)
[void](Add-Box $s1 132 320 170 28 $PALE 1.5 $false)
[void](Add-Text $s1 326 326 90 18 '내 비밀 숫자' $FB 12)
$d = Add-Box $s1 418 314 44 40 $WHITE 2.5 $false
[void](Add-Text $s1 474 320 80 30 '태블릿에 나온 숫자를 써요' $FM 8.5 $GRAYT)
[void](Add-Text $s1 44 372 120 18 '모둠 금고 비밀번호' $FB 12)
$seatNames = @('첫째', '둘째', '셋째', '넷째', '다섯째')
for ($i = 0; $i -lt 5; $i++) {
  $bx = 178 + $i * 76
  [void](Add-Box $s1 $bx 360 44 38 $WHITE 2 $false)
  [void](Add-Text $s1 ($bx - 16) 401 76 12 ($seatNames[$i] + ' (      )번') $FM 8 $GRAYT 2)
}

# card 2: collect donations
[void](Add-Box $s1 28 436 539 260 $WHITE)
Add-CardHead $s1 436 '2' '의연금 모으기' '답은 그 미션을 푼 친구가 알아요'
for ($i = 0; $i -lt 4; $i++) {
  $ry = 478 + $i * 50
  [void](Add-Box $s1 42 $ry 511 42 $LIGHT 0 $false)
  [void](Add-Text $s1 52 ($ry + 13) 92 18 '(      )번 친구' $FB 11.5)
  [void](Add-Text $s1 150 ($ry + 14) 30 16 '미션' $FM 10 $GRAYT)
  [void](Add-Box $s1 178 ($ry + 8) 130 26 $WHITE 1.2 $false)
  [void](Add-Text $s1 320 ($ry + 14) 20 16 '답' $FM 10 $GRAYT)
  [void](Add-Box $s1 338 ($ry + 8) 152 26 $WHITE 1.2 $false)
  $coin = $s1.Shapes.AddShape(9, 506, $ry + 6, 30, 30); $coin.Fill.Solid(); $coin.Fill.ForeColor.RGB = $WHITE; $coin.Line.ForeColor.RGB = $DARK; $coin.Line.Weight = 2; $coin.Shadow.Visible = 0
  $hole = $s1.Shapes.AddShape(1, 517, $ry + 17, 8, 8); $hole.Fill.Visible = 0; $hole.Line.ForeColor.RGB = $DARK; $hole.Line.Weight = 1.5; $hole.Shadow.Visible = 0
}
[void](Add-Text $s1 44 676 470 16 '엽전 4개를 모으면 태블릿에서 65만 원을 모금함에 넣어요. 다 맞힌 엽전은 색칠해요.' $FM 10 $DARK)
[void](Add-Text $s1 482 676 50 16 '넣었어요' $FB 10 $DARK 3)
$cb = $s1.Shapes.AddShape(1, 537, 676, 14, 14); $cb.Fill.Solid(); $cb.Fill.ForeColor.RGB = $WHITE; $cb.Line.ForeColor.RGB = $DARK; $cb.Line.Weight = 1.5; $cb.Shadow.Visible = 0

# class donation box
[void](Add-Box $s1 28 708 539 92 $PALE)
[void](Add-Text $s1 44 718 300 20 '우리 반 모금함 1,300만 원' $FT 13 $DARK)
[void](Add-Text $s1 300 721 252 16 '모금함에 넣은 친구 번호에 색칠해요' $FM 9.5 $GRAYT 3)
$nums = @(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 19, 20, 21, 22, 23)
for ($i = 0; $i -lt 20; $i++) { [void](Add-Circle $s1 (44 + $i * 25.6) 758 22 ([string]$nums[$i]) $WHITE 8.5) }
[void](Add-Text $s1 28 806 539 16 '사진: 광문사 터 안내판 Qkqhrhkdtn, 위키미디어 공용, CC BY-SA 3.0 (일부 자름) | 서상돈 위키미디어 공용, CC0 | 의연금 명부 고려, 위키미디어 공용, CC BY 4.0 (일부 자름) | 국채보상운동기념공원 대구광역시, 공공누리 제1유형' $FM 6 $GRAYT 2)
Add-Footer $s1 '5, 6학년 교실 방탈출 | 웹앱 짝꿍 학습지 앞면 (A4 양면 인쇄)'

# ======================= page 2: student back =======================
$s2 = $pres.Slides.Add(2, 12)
Add-Deco $s2
Add-Chip $s2 28 28 104 '내 탐정 수첩 뒷면'
Add-Title $s2 '우리 모둠 ' '기록'
[void](Add-Text $s2 28 96 540 16 '태블릿에 쓴 내용을 옮겨 적고, 한 달 동안 약속을 지켜요.' $FM 11 $GRAYT)

[void](Add-Box $s2 28 122 539 118 $WHITE)
Add-CardHead $s2 122 '3' '생각 나누기' ''
[void](Add-Text $s2 44 162 505 34 '신분도 나이도 다른 사람들이 한마음으로 참여할 수 있었던 까닭은 무엇일까요?' $FB 12.5)
[void](Add-Text $s2 44 200 100 14 '우리 모둠 생각' $FM 9.5 $GRAYT)

Add-Line $s2 44 226 553 226

[void](Add-Box $s2 28 252 539 178 $WHITE)
Add-CardHead $s2 252 '4' '내가 맡은 칸' '내 자리에 ○ 해요'
$roles = @('의연 증서의 줄일 것, 호외의 알게 된 사실 1', '의연 증서의 모을 것, 호외의 알게 된 사실 2', '의연 증서의 약속 기간, 호외의 알게 된 사실 3', '호외의 머리기사 장소, 모둠 생각 한 문장', '호외의 홍보 문구')
for ($i = 0; $i -lt 5; $i++) {
  $ry = 290 + $i * 22
  [void](Add-Box $s2 44 $ry 58 18 $LIGHT 1 $false)
  [void](Add-Text $s2 44 ($ry + 2) 58 14 $seatNames[$i] $FB 9.5 $DARK 2)
  [void](Add-Text $s2 112 ($ry + 2) 440 14 $roles[$i] $FM 10 $DARK)
}
[void](Add-Text $s2 44 404 90 16 '내가 쓴 내용' $FB 11)
Add-Line $s2 130 418 553 418

[void](Add-Box $s2 28 442 539 150 $WHITE)
Add-CardHead $s2 442 '5' '우리 모둠 호외' ''
[void](Add-Photo $s2 (Join-Path $ImgDir 'news-1907.jpg') 44 478 222 108)
[void](Add-Text $s2 280 480 272 28 '1907년 5월 18일 자 대한매일신보 영문판 1면이에요. 그때 신문은 이렇게 생겼어요.' $FM 9 $GRAYT)
[void](Add-Text $s2 280 518 272 18 '(                     )에서 시작된 국채보상운동!' $FB 11)
[void](Add-Text $s2 280 552 60 16 '홍보 문구' $FM 9.5 $GRAYT)
Add-Line $s2 280 576 553 576

[void](Add-Box $s2 28 604 539 128 $WHITE)
Add-CardHead $s2 604 '6' '내 약속과 한 달 실천' '지킨 주에 ○ 해요'
[void](Add-Text $s2 44 646 60 18 '내 약속' $FB 12)
[void](Add-Box $s2 104 640 449 28 $PALE 1.5 $false)
for ($i = 0; $i -lt 4; $i++) {
  $wx = 44 + $i * 128
  [void](Add-Box $s2 $wx 680 118 42 $WHITE 1.5 $false)
  [void](Add-Text $s2 ($wx + 10) 693 40 16 (([string]($i + 1)) + '주') $FT 12 $DARK)
  $o = $s2.Shapes.AddShape(9, $wx + 84, 689, 24, 24); $o.Fill.Visible = 0; $o.Line.ForeColor.RGB = $LINEC; $o.Line.Weight = 1.5; $o.Shadow.Visible = 0
}

[void](Add-Box $s2 28 744 539 56 $PALE)
[void](Add-Text $s2 44 754 300 16 '오늘 새로 알게 된 것 한 가지' $FB 11)
Add-Line $s2 44 788 553 788
[void](Add-Text $s2 28 806 539 12 '자료: 대한매일신보 영문판(The Korea Daily News) 1907년 5월 18일 자 1면, 퍼블릭 도메인, 위키미디어 공용 (윗부분만 자름)' $FM 6 $GRAYT 2)
Add-Footer $s2 '5, 6학년 교실 방탈출 | 웹앱 짝꿍 학습지 뒷면 (A4 양면 인쇄)'

# ======================= page 3: teacher answer key =======================
$s3 = $pres.Slides.Add(3, 12)
Add-Deco $s3
Add-Chip $s3 28 28 84 '교사용 답지'
Add-Title $s3 '정답과 ' '모둠 표'
[void](Add-Text $s3 28 96 540 16 '학생 학습지에는 정답이 없어요. 이 쪽은 선생님만 봐요.' $FM 11 $GRAYT)

function Style-Table($tbl, $widths, $headFill) {
  for ($c = 1; $c -le $widths.Count; $c++) { $tbl.Columns.Item($c).Width = [single]$widths[$c - 1] }
  for ($r = 1; $r -le $tbl.Rows.Count; $r++) {
    for ($c = 1; $c -le $tbl.Columns.Count; $c++) {
      $cell = $tbl.Cell($r, $c); $sh = $cell.Shape
      $sh.Fill.Solid(); $sh.Fill.ForeColor.RGB = $(if ($r -eq 1) { $headFill } else { $WHITE })
      $tf = $sh.TextFrame; $tf.MarginLeft = 4; $tf.MarginRight = 4; $tf.MarginTop = 3; $tf.MarginBottom = 3; $tf.VerticalAnchor = 3
      Set-Font $tf.TextRange $(if ($r -eq 1) { $FB } else { $FM }) 9.5 $DARK 2
      foreach ($b in 1, 2, 3, 4) { $bd = $cell.Borders.Item($b); $bd.Visible = -1; $bd.ForeColor.RGB = $DARK; $bd.Weight = 1 }
    }
  }
}

[void](Add-Box $s3 28 122 539 210 $WHITE)
Add-CardHead $s3 122 '1' '미션 정답' '빨간 글씨가 비밀 숫자'
$t1 = $s3.Shapes.AddTable(6, 4, 42, 160, 511, 160).Table
$rows1 = @(
  @('미션', '질문과 답', '비밀 숫자', '친구 퀴즈와 답'),
  @('1 광문사의 꿈', '광문사가 세워진 해: 1906년', '6', '나라의 힘을 기르려고 힘쓴 일: 학교 세우기'),
  @('2 운동의 시작', '국채보상운동이 시작된 해: 1907년', '0', '나랏빚을 갚자고 제안한 날: 1월 29일'),
  @('3 서상돈의 계산', '담배를 끊자고 한 기간: 석 달', '3', '무엇을 끊어 돈을 모으자고 했나: 담배'),
  @('4 남일동 부인들', '패물폐지부인회를 만든 부인: 일곱 명', '7', '부인 일곱 명이 만든 모임: 패물폐지부인회'),
  @('5 대구시민의 날', '대구시민의 날: 2월 21일', '1', '군민대회를 연 곳: 북후정'))
for ($r = 0; $r -lt 6; $r++) { for ($c = 0; $c -lt 4; $c++) { $t1.Cell($r + 1, $c + 1).Shape.TextFrame.TextRange.Text = $rows1[$r][$c] } }
Style-Table $t1 @(92, 170, 54, 195) $PALE
for ($r = 2; $r -le 6; $r++) { $tr = $t1.Cell($r, 3).Shape.TextFrame.TextRange; $tr.Font.Color.RGB = $RED; $tr.Font.Name = $FT; $tr.Font.NameFarEast = $FT; $tr.Font.Size = 14 }

[void](Add-Box $s3 28 344 539 196 $WHITE)
Add-CardHead $s3 344 '2' '모둠 금고 비밀번호' '칸 안: 번호 (미션)'
$t2 = $s3.Shapes.AddTable(5, 7, 42, 382, 511, 140).Table
$heads = @('모둠', '비밀번호', '첫째', '둘째', '셋째', '넷째', '다섯째')
for ($c = 0; $c -lt 7; $c++) { $t2.Cell(1, $c + 1).Shape.TextFrame.TextRange.Text = $heads[$c] }
$codes = @('60371', '03716', '37160', '71603')
for ($g = 1; $g -le 4; $g++) {
  $t2.Cell($g + 1, 1).Shape.TextFrame.TextRange.Text = ([string]$g + '모둠')
  $t2.Cell($g + 1, 2).Shape.TextFrame.TextRange.Text = $codes[$g - 1]
  for ($seat = 1; $seat -le 5; $seat++) {
    $no = $nums[($g - 1) * 5 + $seat - 1]; $m = (($seat - 1) + ($g - 1)) % 5 + 1
    $t2.Cell($g + 1, $seat + 2).Shape.TextFrame.TextRange.Text = ([string]$no + '번 (' + $m + ')')
  }
}
Style-Table $t2 @(60, 86, 73, 73, 73, 73, 73) $PALE
for ($r = 2; $r -le 5; $r++) { $tr = $t2.Cell($r, 2).Shape.TextFrame.TextRange; $tr.Font.Color.RGB = $RED; $tr.Font.Name = $FT; $tr.Font.NameFarEast = $FT; $tr.Font.Size = 14 }

[void](Add-Box $s3 28 552 539 248 $PALE)
Add-CardHead $s3 552 '3' '수업 진행 메모' ''
$tips = @(
  '학생 링크: hsy1800-create.github.io/1907-daegu-escape   선생님 화면 비밀번호: 4129',
  '수업 중 선생님은 누를 것이 없어요. 선생님 화면을 TV에 띄우면 반 모금함과 모둠별 엽전이 실시간으로 보여요.',
  '친구 퀴즈를 틀리면 그 문제는 8초 동안 잠겨요. 마구 누르지 말고 그 미션을 푼 친구에게 물어보게 해 주세요.',
  '결석생 자리 숫자는 위 표에서 알려 주세요. 그 번호는 남는 태블릿으로 다른 학생이 대신 풀어요.',
  '의연 증서와 호외는 자리마다 맡은 칸이 있어요. 친구가 쓴 칸은 모둠 태블릿 5대에 바로 보여요.',
  '수업이 끝나면 선생님 화면의 새 수업 시작을 눌러요. 반 모금함이 지워지고 모든 태블릿이 처음 화면으로 돌아가요.')
for ($i = 0; $i -lt $tips.Count; $i++) {
  $ty = 594 + $i * 33
  [void](Add-Circle $s3 44 ($ty + 1) 14 '' $WHITE 6)
  [void](Add-Text $s3 66 $ty 486 30 $tips[$i] $FM 10 $DARK)
}
Add-Footer $s3 '5, 6학년 교실 방탈출 | 웹앱 짝꿍 학습지 교사용 답지 (A4)'

$pptx = Join-Path $OutDir '웹앱 짝꿍 학습지_1907 대구 방탈출(A4 양면 인쇄용).pptx'
$pdf = Join-Path $OutDir '웹앱 짝꿍 학습지_1907 대구 방탈출(A4 양면 인쇄용).pdf'
$pres.SaveAs($pptx)
$pres.SaveAs($pdf, 32)
$prev = Join-Path $env:TEMP 'ws_app_prev'
New-Item -ItemType Directory -Force $prev | Out-Null
for ($i = 1; $i -le $pres.Slides.Count; $i++) { $pres.Slides.Item($i).Export((Join-Path $prev "p$i.png"), 'PNG', 1191, 1684) }
$pres.Close(); $pp.Quit()
"saved: $pptx"
"preview: $prev"
