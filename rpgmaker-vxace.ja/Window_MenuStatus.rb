#
# メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#

class Window_MenuStatus < Window_Selectable
  #
  # 公開インスタンス変数
  #
  #
  attr_reader   :pending_index            # 保留位置（並び替え用）
  #
  # オブジェクト初期化
  #
  #
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @pending_index = -1
    refresh
  end
  #
  # ウィンドウ幅の取得
  #
  #
  def window_width
    Graphics.width - 160
  end
  #
  # ウィンドウ高さの取得
  #
  #
  def window_height
    Graphics.height
  end
  #
  # 項目数の取得
  #
  #
  def item_max
    $game_party.members.size
  end
  #
  # 項目の高さを取得
  #
  #
  def item_height
    (height - standard_padding * 2) / 4
  end
  #
  # 項目の描画
  #
  #
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled)
    draw_actor_simple_status(actor, rect.x + 108, rect.y + line_height / 2)
  end
  #
  # 項目の背景を描画
  #
  #
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  #
  # 決定ボタンが押されたときの処理
  #
  #
  def process_ok
    super
    $game_party.menu_actor = $game_party.members[index]
  end
  #
  # 前回の選択位置を復帰
  #
  #
  def select_last
    select($game_party.menu_actor.index || 0)
  end
  #
  # 保留位置（並び替え用）の設定
  #
  #
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
end