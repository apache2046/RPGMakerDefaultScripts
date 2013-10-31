#encoding:utf-8
#
# 名字输入画面中，选择文字的窗口。
#

class Window_NameInput < Window_Selectable
  #
  # 文字表（欧洲）
  #
  #
  LATIN1 = [ 'A','B','C','D','E',  'a','b','c','d','e',
             'F','G','H','I','J',  'f','g','h','i','j',
             'K','L','M','N','O',  'k','l','m','n','o',
             'P','Q','R','S','T',  'p','q','r','s','t',
             'U','V','W','X','Y',  'u','v','w','x','y',
             'Z','[',']','^','_',  'z','{','}','|','~',
             '0','1','2','3','4',  '!','#','$','%','&',
             '5','6','7','8','9',  '(',')','*','+','-',
             '/','=','@','<','>',  ':',';',' ','Page','OK']
  LATIN2 = [ 'Á','É','Í','Ó','Ú',  'á','é','í','ó','ú',
             'À','È','Ì','Ò','Ù',  'à','è','ì','ò','ù',
             'Â','Ê','Î','Ô','Û',  'â','ê','î','ô','û',
             'Ä','Ë','Ï','Ö','Ü',  'ä','ë','ï','ö','ü',
             'Ā','Ē','Ī','Ō','Ū',  'ā','ē','ī','ō','ū',
             'Ã','Å','Æ','Ç','Ð',  'ã','å','æ','ç','ð',
             'Ñ','Õ','Ø','Š','Ŵ',  'ñ','õ','ø','š','ŵ',
             'Ý','Ŷ','Ÿ','Ž','Þ',  'ý','ÿ','ŷ','ž','þ',
             'Ĳ','Œ','ĳ','œ','ß',  '«','»',' ','Page','OK']
  #
  # 文字表（日本）
  #
  #
  JAPAN1 = [ 'あ','い','う','え','お',  'が','ぎ','ぐ','げ','ご',
             'か','き','く','け','こ',  'ざ','じ','ず','ぜ','ぞ',
             'さ','し','す','せ','そ',  'だ','ぢ','づ','で','ど',
             'た','ち','つ','て','と',  'ば','び','ぶ','べ','ぼ',
             'な','に','ぬ','ね','の',  'ぱ','ぴ','ぷ','ぺ','ぽ',
             'は','ひ','ふ','へ','ほ',  'ぁ','ぃ','ぅ','ぇ','ぉ',
             'ま','み','む','め','も',  'っ','ゃ','ゅ','ょ','ゎ',
             'や','ゆ','よ','わ','ん',  'ー','～','・','＝','☆',
             'ら','り','る','れ','ろ',  'ゔ','','　','カナ','决定']
  JAPAN2 = [ 'ア','イ','ウ','エ','オ',  'ガ','ギ','グ','ゲ','ゴ',
             'カ','キ','ク','ケ','コ',  'ザ','ジ','ズ','ゼ','ゾ',
             'サ','シ','ス','セ','ソ',  'ダ','ヂ','ヅ','デ','ド',
             'タ','チ','ツ','テ','ト',  'バ','ビ','ブ','ベ','ボ',
             'ナ','ニ','ヌ','ネ','ノ',  'パ','ピ','プ','ペ','ポ',
             'ハ','ヒ','フ','ヘ','ホ',  'ァ','ィ','ゥ','ェ','ォ',
             'マ','ミ','ム','メ','モ',  'ッ','ャ','ュ','ョ','ヮ',
             'ヤ','ユ','ヨ','ワ','ン',  'ー','～','・','＝','☆',
             'ラ','リ','ル','レ','ロ',  'ヴ','ヲ','　','英数','确定']
  JAPAN3 = [ 'Ａ','Ｂ','Ｃ','Ｄ','Ｅ',  'ａ','ｂ','ｃ','ｄ','ｅ',
             'Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',  'ｆ','ｇ','ｈ','ｉ','ｊ',
             'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ',  'ｋ','ｌ','ｍ','ｎ','ｏ',
             'Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',  'ｐ','ｑ','ｒ','ｓ','ｔ',
             'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ',  'ｕ','ｖ','ｗ','ｘ','ｙ',
             'Ｚ','［','］','＾','＿',  'ｚ','｛','｝','｜','～',
             '０','１','２','３','４',  '！','＃','＄','％','＆',
             '５','６','７','８','９',  '（','）','＊','＋','－',
             '／','＝','＠','＜','＞',  '：','；','　','かな','确定']
  #
  # 初始化对象
  #
  #
  def initialize(edit_window)
    super(edit_window.x, edit_window.y + edit_window.height + 8,
          edit_window.width, fitting_height(9))
    @edit_window = edit_window
    @page = 0
    @index = 0
    refresh
    update_cursor
    activate
  end
  #
  # 获取字表
  #
  #
  def table
    return [JAPAN1, JAPAN2, JAPAN3] if $game_system.japanese?
    return [LATIN1, LATIN2]
  end
  #
  # 获取文字
  #
  #
  def character
    @index < 88 ? table[@page][@index] : ""
  end
  #
  # 判定光标位置是否在“切换”上（平假／片假）
  #
  #
  def is_page_change?
    @index == 88
  end
  #
  # 判定光标位置是否在“确定”上
  #
  #
  def is_ok?
    @index == 89
  end
  #
  # 获取项目的绘制矩形
  #
  #
  def item_rect(index)
    rect = Rect.new
    rect.x = index % 10 * 32 + index % 10 / 5 * 16
    rect.y = index / 10 * line_height
    rect.width = 32
    rect.height = line_height
    rect
  end
  #
  # 刷新
  #
  #
  def refresh
    contents.clear
    change_color(normal_color)
    90.times {|i| draw_text(item_rect(i), table[@page][i], 1) }
  end
  #
  # 更新光标
  #
  #
  def update_cursor
    cursor_rect.set(item_rect(@index))
  end
  #
  # 判定光标是否可以移动
  #
  #
  def cursor_movable?
    active
  end
  #
  # 光标向下移动
  #
  # wrap : 允许循环
  #
  def cursor_down(wrap)
    if @index < 80 or wrap
      @index = (index + 10) % 90
    end
  end
  #
  # 光标向上移动
  #
  # wrap : 允许循环
  #
  def cursor_up(wrap)
    if @index >= 10 or wrap
      @index = (index + 80) % 90
    end
  end
  #
  # 光标向右移动
  #
  # wrap : 允许循环
  #
  def cursor_right(wrap)
    if @index % 10 < 9
      @index += 1
    elsif wrap
      @index -= 9
    end
  end
  #
  # 光标向左移动
  #
  # wrap : 允许循环
  #
  def cursor_left(wrap)
    if @index % 10 > 0
      @index -= 1
    elsif wrap
      @index += 9
    end
  end
  #
  # 向下一页移动
  #
  #
  def cursor_pagedown
    @page = (@page + 1) % table.size
    refresh
  end
  #
  # 向上一页移动
  #
  #
  def cursor_pageup
    @page = (@page + table.size - 1) % table.size
    refresh
  end
  #
  # 处理光标的移动
  #
  #
  def process_cursor_move
    last_page = @page
    super
    update_cursor
    Sound.play_cursor if @page != last_page
  end
  #
  # “确定”、“删除字符”和“取消输入”的处理
  #
  #
  def process_handling
    return unless open? && active
    process_jump if Input.trigger?(:A)
    process_back if Input.repeat?(:B)
    process_ok   if Input.trigger?(:C)
  end
  #
  # 跳转“确定”
  #
  #
  def process_jump
    if @index != 89
      @index = 89
      Sound.play_cursor
    end
  end
  #
  # 后退一个字符
  #
  #
  def process_back
    Sound.play_cancel if @edit_window.back
  end
  #
  # 按下确定键时的处理
  #
  #
  def process_ok
    if !character.empty?
      on_name_add
    elsif is_page_change?
      Sound.play_ok
      cursor_pagedown
    elsif is_ok?
      on_name_ok
    end
  end
  #
  # 添加名字字符
  #
  #
  def on_name_add
    if @edit_window.add(character)
      Sound.play_ok
    else
      Sound.play_buzzer
    end
  end
  #
  # 确定名字
  #
  #
  def on_name_ok
    if @edit_window.name.empty?
      if @edit_window.restore_default
        Sound.play_ok
      else
        Sound.play_buzzer
      end
    else
      Sound.play_ok
      call_ok_handler
    end
  end
end