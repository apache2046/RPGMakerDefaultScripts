#encoding:utf-8
#
# 裝備畫面中，顯示角色能力值變化的視窗。
#

class Window_EquipStatus < Window_Base
  #
  # 初始化物件
  #
  #
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    @temp_actor = nil
    refresh
  end
  #
  # 取得視窗的寬度
  #
  #
  def window_width
    return 208
  end
  #
  # 取得視窗的高度
  #
  #
  def window_height
    fitting_height(visible_line_number)
  end
  #
  # 取得顯示行數
  #
  #
  def visible_line_number
    return 7
  end
  #
  # 設定角色
  #
  #
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #
  # 重新整理
  #
  #
  def refresh
    contents.clear
    draw_actor_name(@actor, 4, 0) if @actor
    6.times {|i| draw_item(0, line_height * (1 + i), 2 + i) }
  end
  #
  # 設定更換裝備後的臨時角色
  #
  #
  def set_temp_actor(temp_actor)
    return if @temp_actor == temp_actor
    @temp_actor = temp_actor
    refresh
  end
  #
  # 繪制專案
  #
  #
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 94, y, param_id) if @actor
    draw_right_arrow(x + 126, y)
    draw_new_param(x + 150, y, param_id) if @temp_actor
  end
  #
  # 繪制能力值的名字
  #
  #
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #
  # 繪制當前能力值
  #
  #
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 32, line_height, @actor.param(param_id), 2)
  end
  #
  # 繪制右方向箭頭
  #
  #
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 22, line_height, "→", 1)
  end
  #
  # 繪制更換裝備後的能力值
  #
  #
  def draw_new_param(x, y, param_id)
    new_value = @temp_actor.param(param_id)
    change_color(param_change_color(new_value - @actor.param(param_id)))
    draw_text(x, y, 32, line_height, new_value, 2)
  end
end
